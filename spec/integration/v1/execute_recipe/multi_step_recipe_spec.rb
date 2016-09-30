require 'rails_helper'
require_relative '../version'
require 'sidekiq/testing'

Sidekiq::Testing.inline!

describe "User executes a recipe with multiple real steps" do

  # URL: /api/recipes/:id/execute
  # Method: GET
  # Execute a specific recipe belonging to the current user

  # curl -H "Content-Type: application/json, Accept: application/vnd.ink.v1, uid: user@example.com, auth_token: asdf" -X GET http://localhost:3000/api/recipes/:id/execute

  describe "POST execute recipe" do

    let!(:user)             { create(:user, password: "password", password_confirmation: "password") }
    let!(:auth_headers)     { user.create_new_auth_token }
    let!(:html_file)         { fixture_file_upload('files/test.html', 'text/html') }
    let!(:docx_file)         { fixture_file_upload('files/SampleStyles.docx', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document') }

    let!(:recipe)           { create(:recipe, user: user) }

    let!(:execution_params) {
      {
          input_file: docx_file,
          id: recipe.id
      }
    }

    let!(:pandoc)     { create(:step_class, name: "DocxToHtmlPandoc") }
    let!(:rot13)      { create(:step_class, name: "RotThirteen") }
    let!(:epub)       { create(:step_class, name: "EpubCalibre") }
    let!(:step1)      { create(:recipe_step, recipe: recipe, position: 1, step_class: pandoc) }
    let!(:step2)      { create(:recipe_step, recipe: recipe, position: 2, step_class: rot13) }
    let!(:step3)      { create(:recipe_step, recipe: recipe, position: 3, step_class: epub) }

    context 'and execution is successful' do
      it 'should return the objects' do
        perform_execute_request(auth_headers, execution_params)

        expect(response.status).to eq(200)
        expect(body_as_json['conversion_chain']['successful'])
        expect(body_as_json['conversion_chain']['conversion_steps'].count).to eq 3
        body_as_json['conversion_chain']['conversion_steps'].map do |s|
          expect(s['conversion_errors']).to eq ""
        end
        # expect(body_as_json['conversion_chain']['conversion_steps'].sort_by{|e| e['position'].to_i}.map{|e| e['output_file_path']}).to eq [true, true]
      end

      it 'should return a ConversionChain object' do
        perform_execute_request(auth_headers, execution_params)

        conversion_chain = recipe.reload.conversion_chains.first

        expect(body_as_json['conversion_chain']['recipe_id']).to eq conversion_chain.recipe_id
        expect(body_as_json['conversion_chain']['executed_at']).to eq conversion_chain.executed_at.iso8601
        expect(body_as_json['conversion_chain']['input_file_name']).to eq conversion_chain.input_file_name
        expect(body_as_json['conversion_chain']['executed_at_for_humans']).to_not be_nil
        expect(body_as_json['conversion_chain']['successful']).to eq true
      end

      it 'should also return the steps' do
        perform_execute_request(auth_headers, execution_params)

        expect(body_as_json['conversion_chain']['conversion_steps'].count).to eq 3
        body_as_json['conversion_chain']['conversion_steps'].each do |result|
          expect(result['conversion_errors']).to eq ""
        end
      end
    end

    context 'and execution fails' do
      let!(:boobytrapped_step)      { Conversion::Steps::RotThirteen.new }
      let(:step_spy)                { double(:epub_calibre) }

      before do
        allow(Conversion::Steps::RotThirteen).to receive(:new).and_return boobytrapped_step
        allow(boobytrapped_step).to receive(:convert_file) { raise "Oh noes! Error!" }
      end

      it 'halts execution after a failed step' do
        perform_execute_request(auth_headers, execution_params)

        expect(response.status).to eq(200)
        expect(body_as_json['conversion_chain']['successful']).to eq false
        expect(body_as_json['conversion_chain']['conversion_steps'].count).to eq 3
        expect(body_as_json['conversion_chain']['conversion_steps'].sort_by{|e| e['position'].to_i}.map{|e| e['conversion_errors']}).to eq ["", "Oh noes! Error!", ""]
        expect(body_as_json['conversion_chain']['conversion_steps'].last['executed_at']).to_not be_nil
      end

      it 'does not execute the later steps' do
        allow(Conversion::Steps::EpubCalibre).to receive(:new).and_return(step_spy)
        allow(step_spy).to receive(:execute)

        expect(step_spy).to_not have_received(:execute)
      end
    end
  end
  
  def perform_execute_request(auth_headers, data)
    execute_recipe_request(version, auth_headers, data)
  end
end