require 'rails_helper'
require_relative '../version'
require 'sidekiq/testing'

Sidekiq::Testing.inline!

describe "User executes a recipe and an event is triggered" do

  describe "POST execute recipe" do

    let!(:user)             { create(:user) }
    let!(:auth_headers)     { user.create_new_auth_token }
    let!(:html_file)        { fixture_file_upload('files/test.html', 'text/html') }

    let!(:rot13)            { rot_thirteen_step_class.to_s }
    let!(:base)             { base_step_class.to_s }
    let!(:recipe)           { create(:recipe, user: user, step_classes: [rot13, base]) }

    let!(:execution_params) {
      {
          input_files: html_file,
          id: recipe.id
      }
    }


    before do
      stub_event_request
    end

    context 'and execution is successful' do
      it 'fires the events' do
        perform_execute_request(auth_headers, execution_params)

        expect_event(channels: execution_channel, event: process_chain_started_processing_event, data: { recipe_id: recipe.id, chain_id: ProcessChain.last.id } )
        expect_event(channels: execution_channel, event: process_chain_done_processing_event, data: { recipe_id: recipe.id, chain_id: ProcessChain.last.id } )
        expect_event(channels: execution_channel, event: process_step_started_event, data: { recipe_id: recipe.id, chain_id: ProcessChain.last.id } )
        expect_event(channels: execution_channel, event: process_step_finished_event, data: { recipe_id: recipe.id, chain_id: ProcessChain.last.id } )
      end
    end

    context 'and execution fails' do
      before do
        allow_any_instance_of(Execution::RecipeExecutionRunner).to receive(:build_pipeline) { raise "FRAMEWORK ERROR" }
      end

      it 'sends the failed chain information back to the client' do
        perform_execute_request(auth_headers, execution_params)

        expect(response.status).to eq(200)

        expect_event(channels: execution_channel, event: process_chain_started_processing_event, data: { recipe_id: recipe.id, chain_id: ProcessChain.last.id})
        expect_event(channels: execution_channel, event: process_chain_error_event, data: { recipe_id: recipe.id, chain_id: ProcessChain.last.id})
      end
    end

    def expect_event(channels:, event:, data: {})
      expect(WebMock).to have_requested(:post,  /#{Pusher.host}\:#{Pusher.port}\/apps\/#{Pusher.app_id}\/events/).with(body: hash_including({"name" => event, "channels" => [channels].flatten, "data" => "#{data.to_json}"}))
    end

    def stub_event_request
      stub_request(:post, "#{Pusher.host}:#{Pusher.port}")
    end

    def execution_channel
      "process_chain_#{ProcessChain.last.id}"
    end

  end
  
  def perform_execute_request(auth_headers, data)
    execute_recipe_request(version, auth_headers, data)
  end
end