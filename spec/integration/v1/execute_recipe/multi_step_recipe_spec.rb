require 'rails_helper'
require_relative '../version'
require 'sidekiq/testing'

Sidekiq::Testing.inline!

describe "User executes a recipe with multiple real steps" do

  # URL: /api/recipes/:id/execute
  # Method: POST
  # Execute a specific recipe belonging to the current user

  # curl -H "Content-Type: application/json, Accept: application/vnd.ink.v1, uid: user@example.com, auth_token: asdf" -X POST http://localhost:3000/api/recipes/:id/execute

  describe "POST execute recipe" do

    let!(:user)             { create(:user, password: "password", password_confirmation: "password") }
    let!(:auth_headers)     { user.create_new_auth_token }
    let!(:html_file)        { fixture_file_upload('files/test.html', 'text/html') }
    let!(:docx_file)        { fixture_file_upload('files/SampleStyles.docx', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document') }

    let!(:recipe)           { create(:recipe, user: user) }

    let!(:execution_params) {
      {
          input_file: docx_file,
          id: recipe.id
      }
    }

    let!(:pandoc)     { "DocxToHtmlPandocStep" }
    let!(:rot13)      { "RotThirteenStep" }
    let!(:epub)       { "EpubCalibreStep" }
    let!(:step1)      { create(:recipe_step, recipe: recipe, position: 1, step_class_name: pandoc) }
    let!(:step2)      { create(:recipe_step, recipe: recipe, position: 2, step_class_name: rot13) }
    let!(:step3)      { create(:recipe_step, recipe: recipe, position: 3, step_class_name: epub) }

    context 'and execution is successful' do
      it 'returns the objects' do
        perform_execute_request(auth_headers, execution_params)

        expect(response.status).to eq(200)
        expect(body_as_json['process_chain']['successful'])
        expect(body_as_json['process_chain']['process_steps'].count).to eq 3
        body_as_json['process_chain']['process_steps'].map do |s|
          expect(s['execution_errors']).to eq ""
        end
      end

      it 'returns a ProcessChain object' do
        perform_execute_request(auth_headers, execution_params)

        process_chain = recipe.reload.process_chains.first

        expect(body_as_json['process_chain']['recipe_id']).to eq process_chain.recipe_id
        expect(body_as_json['process_chain']['executed_at']).to eq process_chain.executed_at.iso8601
        expect(body_as_json['process_chain']['input_file_name']).to eq process_chain.input_file_name
        expect(body_as_json['process_chain']['executed_at_for_humans']).to_not be_nil
        expect(body_as_json['process_chain']['successful']).to eq true
      end

      it 'also returns the steps' do
        perform_execute_request(auth_headers, execution_params)

        expect(body_as_json['process_chain']['process_steps'].count).to eq 3
        body_as_json['process_chain']['process_steps'].each do |result|
          expect(result['execution_errors']).to eq ""
        end
      end
    end

    context 'and execution fails' do
      let!(:boobytrapped_step)      { RotThirteenStep.new(process_step: process_step_spy) }
      let!(:step_spy)               { double(:epub_calibre) }
      let!(:process_step_spy)       { create(:process_step, position: 2, step_class_name: "RotThirteenStep")}

      before do
        allow(ProcessStep).to receive(:new).and_call_original
        allow(ProcessStep).to receive(:new).with(position: 2, step_class_name: "RotThirteenStep").and_return(process_step_spy)
        allow(RotThirteenStep).to receive(:new).and_return boobytrapped_step
        allow(boobytrapped_step).to receive(:perform_step) { raise "Oh noes! Error!" }
      end

      it 'halts execution after a failed step' do
        perform_execute_request(auth_headers, execution_params)

        expect(response.status).to eq(200)
        expect(body_as_json['process_chain']['successful']).to eq false
        expect(body_as_json['process_chain']['process_steps'].count).to eq 3
        expect(body_as_json['process_chain']['process_steps'].sort_by{|e| e['position'].to_i}.map{|e| e['execution_errors']}).to eq ["", "Oh noes! Error!", ""]
        expect(body_as_json['process_chain']['process_steps'].last['started_at']).to be_nil
        expect(body_as_json['process_chain']['process_steps'].last['finished_at']).to be_nil
      end

      it 'does not execute the later steps' do
        allow(EpubCalibreStep).to receive(:new).and_return(step_spy)
        allow(step_spy).to receive(:execute)

        expect(step_spy).to_not have_received(:execute)
      end
    end
  end
  
  def perform_execute_request(auth_headers, data)
    execute_recipe_request(version, auth_headers, data)
  end
end