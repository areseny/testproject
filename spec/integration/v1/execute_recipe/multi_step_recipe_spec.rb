require 'rails_helper'
require_relative '../version'
require 'sidekiq/testing'

Sidekiq::Testing.inline!

describe "Account executes a recipe with multiple real steps" do

  # URL: /api/recipes/:id/execute
  # Method: POST
  # Execute a specific recipe belonging to the current account

  # curl -H "Content-Type: application/json, Accept: application/vnd.ink.v1, uid: account@example.com, auth_token: asdf" -X POST --form "input_files=[@my-file.txt], callback_url=mysite.com/callback" http://localhost:3000/api/recipes/:id/execute

  describe "POST execute recipe" do

    let!(:account)             { create(:account, password: "password", password_confirmation: "password") }
    let!(:auth_headers)     { account.create_new_auth_token }
    let!(:html_file)        { fixture_file_upload('files/test.html', 'text/html') }
    let!(:docx_file)        { fixture_file_upload('files/SampleStyles.docx', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document') }

    let!(:recipe)           { create(:recipe, account: account, step_classes: [pandoc, rot13, epub]) }

    let!(:execution_params) {
      {
          input_files: docx_file,
          id: recipe.id
      }
    }

    let!(:pandoc)     { pandoc_docx_to_html_step_class.to_s }
    let!(:rot13)      { rot_thirteen_step_class.to_s }
    let!(:epub)       { epub_calibre_step_class.to_s }

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
        expect(body_as_json['process_chain']['finished_at']).to_not be_nil
        expect(body_as_json['process_chain']['input_file_manifest']).to match(process_chain.input_file_manifest.map(&:stringify_keys))
        expect(body_as_json['process_chain']['output_file_manifest']).to match(process_chain.output_file_manifest.map(&:stringify_keys))
      end

      it 'also returns the steps' do
        perform_execute_request(auth_headers, execution_params)

        expect(body_as_json['process_chain']['process_steps'].count).to eq 3
        body_as_json['process_chain']['process_steps'].sort_by{|e| e['position'].to_i}.each do |result|
          expect(result['execution_errors']).to eq ""
          expect(result['successful']).to eq true
          expect(result['started_at']).to_not be_nil
          expect(result['finished_at']).to_not be_nil
          expect(result['output_file_manifest']).to_not be_nil
        end
      end
    end

    context 'and execution fails' do
      let!(:step_spy)               { double(:epub_calibre, errors: [], version: "1", started_at: nil, finished_at: nil, notes: [], successful: false) }
      before do
        allow_any_instance_of(rot_thirteen_step_class).to receive(:perform_step) { raise "Oh noes! Error!" }
      end

      it 'halts execution after a failed step' do
        perform_execute_request(auth_headers, execution_params)

        expect(response.status).to eq(200)
        expect(body_as_json['process_chain']['successful']).to eq nil
        expect(body_as_json['process_chain']['process_steps'].count).to eq 3
        expect(body_as_json['process_chain']['process_steps'].sort_by{|e| e['position'].to_i}.map{|e| e['execution_errors']}).to eq ["", "Oh noes! Error!", ""]
        expect(body_as_json['process_chain']['process_steps'].sort_by{|e| e['position'].to_i}.map{|e| e['notes']}).to eq ["", "", ""]
        expect(body_as_json['process_chain']['process_steps'].last['started_at']).to be_nil
        expect(body_as_json['process_chain']['process_steps'].last['finished_at']).to be_nil
      end

      it 'does not execute the later steps' do
        allow(epub_calibre_step_class).to receive(:new).and_return(step_spy)
        allow(step_spy).to receive(:execute)
        allow(step_spy).to receive(:successful).and_return(nil)

        perform_execute_request(auth_headers, execution_params)

        expect(step_spy).to_not have_received(:execute)
      end
    end
  end
  
  def perform_execute_request(auth_headers, data)
    execute_recipe_request(version, auth_headers, data)
  end
end