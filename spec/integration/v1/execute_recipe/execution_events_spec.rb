require 'rails_helper'
require_relative '../version'
require 'sidekiq/testing'

Sidekiq::Testing.inline!

describe "Account executes a recipe and an event is triggered" do

  describe "POST execute recipe" do

    let!(:account)             { create(:account) }
    let!(:auth_headers)     { account.new_jwt }
    let!(:html_file)        { fixture_file_upload('files/test.html', 'text/html') }

    let!(:rot13)            { rot_thirteen_step_class.to_s }
    let!(:base)             { base_step_class.to_s }
    let!(:recipe)           { create(:recipe, account: account, step_classes: [rot13]) }

    let!(:execution_params) {
      {
          input_files: html_file,
          id: recipe.id
      }
    }
    let(:chain) { ProcessChain.last }
    let(:step) { ProcessStep.last }

    before do
      stub_event_request
    end

    context 'and execution is successful' do

      it 'fires the chain creation event' do
        perform_execute_request(auth_headers, execution_params)

        expect_event(channels: chain_creation_channel(account.id), event: process_chain_created_event, data: {recipe_id: recipe.id, chain_id: chain.id } )
      end

      it 'fires the chain start event' do
        perform_execute_request(auth_headers, execution_params)

        expect_event(channels: execution_channel, event: process_chain_started_processing_event, data: { recipe_id: recipe.id, chain_id: chain.id } )
      end

      it 'fires the first step start event' do
        perform_execute_request(auth_headers, execution_params)

        expect_event(channels: execution_channel, event: process_step_started_event, data: { recipe_id: recipe.id, chain_id: chain.id, position: 1, version: step.version } )
      end

      it 'fires the first step completion event' do
        perform_execute_request(auth_headers, execution_params)

        # expecting "channels"=>["process_chain_execution"], "data"=>"{\"chain_id\":1,\"position\":1,\"successful\":true,\"notes\":\"[]\",\"execution_errors\":\"[]\",\"recipe_id\":1,\"output_file_manifest\":[{\"path\":\"test_rot13.html\",\"size\":\"84 bytes\"}]}", "name"=>"process_step_completed"})
        # actual "channels":["process_chain_execution"],"data":"{\"chain_id\":1,\"position\":1,\"successful\":true,\"notes\":[],\"execution_errors\":[],\"recipe_id\":1,\"output_file_manifest\":[{\"path\":\"test_rot13.html\",\"size\":\"84 bytes\"}]}"}'
        expect_event(channels: execution_channel, event: process_step_finished_event, data: { chain_id: chain.id, position: step.position, successful: step.successful, notes: step.notes, execution_errors: step.execution_errors, recipe_id: recipe.id, output_file_manifest: step.output_file_manifest } )
      end

      it 'fires the chain completion event' do
        perform_execute_request(auth_headers, execution_params)

        expect_event(channels: execution_channel, event: process_chain_done_processing_event, data: { recipe_id: recipe.id, chain_id: chain.id, output_file_manifest: chain.output_file_manifest } )
      end
    end

    context 'if the step has an error' do
      before do
        allow_any_instance_of(rot_thirteen_step_class).to receive(:perform_step) { raise "oh noes!" }
      end

      it 'fires the chain start event' do
        perform_execute_request(auth_headers, execution_params)

        expect_event(channels: execution_channel, event: process_chain_started_processing_event, data: { recipe_id: recipe.id, chain_id: chain.id } )
      end

      it 'fires the step start event' do
        perform_execute_request(auth_headers, execution_params)

        expect_event(channels: execution_channel, event: process_step_started_event, data: { recipe_id: recipe.id, chain_id: chain.id, position: 1, version: step.version } )
      end

      it 'fires the step completion event (even though it has an error)' do
        perform_execute_request(auth_headers, execution_params)

        expect_event(channels: execution_channel, event: process_step_finished_event, data: { chain_id: chain.id, position: step.position, successful: step.successful, notes: step.notes, execution_errors: step.execution_errors, recipe_id: recipe.id, output_file_manifest: step.output_file_manifest } )
      end

      it 'fires the chain completion with error event' do
        perform_execute_request(auth_headers, execution_params)

        expect_event(channels: execution_channel, event: process_chain_error_event, data: { recipe_id: recipe.id, chain_id: chain.id, output_file_manifest: chain.output_file_manifest } )
      end
    end

    context 'and execution fails' do
      before do
        allow_any_instance_of(Execution::RecipeExecutionRunner).to receive(:execute_process_steps) { raise "FRAMEWORK ERROR" }
      end

      it 'sends the failed chain information back to the client' do
        perform_execute_request(auth_headers, execution_params)

        chain = ProcessChain.last

        expect(response.status).to eq(200)

        expect_event(channels: execution_channel, event: process_chain_started_processing_event, data: { recipe_id: recipe.id, chain_id: chain.id})
        expect_event(channels: execution_channel, event: process_chain_error_event, data: { recipe_id: recipe.id, chain_id: chain.id, output_file_manifest: [], error: "FRAMEWORK ERROR"})
      end
    end

    def expect_event(channels:, event:, data: {})
      expect(WebMock).to have_requested(:post,  /#{Pusher.host}\:#{Pusher.port}\/apps\/#{Pusher.app_id}\/events/).with(body: hash_including({"name" => event, "channels" => [channels].flatten}))#, "data" => "#{data.to_json}"}))
    end

    def stub_event_request
      stub_request(:post, "#{Pusher.host}:#{Pusher.port}")
    end
  end
  
  def perform_execute_request(auth_headers, data)
    execute_recipe_request(version, auth_headers, data)
  end
end