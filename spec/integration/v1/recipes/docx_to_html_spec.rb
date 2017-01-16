require 'rails_helper'
require_relative '../version'
require 'sidekiq/testing'

Sidekiq::Testing.inline!

describe "User executes a single recipe" do

  # URL: /api/recipes/:id/execute
  # Method: GET
  # Execute a specific recipe belonging to the current user

  # curl -H "Content-Type: application/json, Accept: application/vnd.ink.v1, uid: user@example.com, auth_token: asdf" -X GET http://localhost:3000/api/recipes/:id/execute

  describe "POST execute recipe" do

    let!(:user)             { create(:user, password: "password", password_confirmation: "password") }
    let!(:auth_headers)     { user.create_new_auth_token }
    let!(:docx_file)        { fixture_file_upload('files/basic_doc.docx', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document') }

    let!(:recipe)           { create(:recipe, user: user, step_classes: [step_class]) }

    let!(:execution_params) {
      {
          input_files: docx_file,
          id: recipe.id
      }
    }

    context 'if user is signed in' do
      let!(:step_class)  { base_step_class.to_s }
      let!(:step1)       { recipe.recipe_steps.first }

      context 'and execution is successful' do

        before do
          perform_execute_request(auth_headers, execution_params)
        end

        it 'returns the objects' do
          expect(response.status).to eq(200)
          expect(body_as_json['process_chain']['process_steps'].sort_by{|e| e['position'].to_i}.map{|e| e['successful']}).to eq [nil]
        end

        it 'includes the associated steps' do
          expect(body_as_json['process_chain']['process_steps'].count).to eq 1
          body_as_json['process_chain']['process_steps'].map do |s|
            expect(s['execution_errors']).to eq ""
          end
          # expect(body_as_json['process_chain']['process_steps'].sort_by{|e| e['position'].to_i}.map{|e| e['output_file_path']}).to eq [true, true]
        end

      end

    end
  end
  
  def perform_execute_request(auth_headers, data)
    execute_recipe_request(version, auth_headers, data)
  end
end