require 'rails_helper'
require_relative '../version'
require 'sidekiq/testing'

Sidekiq::Testing.inline!

describe "User executes a recipe" do

  # URL: /api/recipes/:id/execute
  # Method: POST
  # Execute a specific recipe belonging to the current user, providing a callback URL

  # curl -H "Content-Type: application/json, Accept: application/vnd.ink.v1, uid: user@example.com, auth_token: asdf" -X POST --form "input_files=[@my-file.txt], callback_url=mysite.com/callback" http://localhost:3000/api/recipes/:id/execute

  describe "POST execute recipe" do

    let!(:user)             { create(:user) }
    let!(:auth_headers)     { user.create_new_auth_token }
    let!(:html_file)        { fixture_file_upload('files/test.html', 'text/html') }

    let!(:execution_params) {
      {
          input_files: html_file,
          id: recipe.id
      }
    }

    context 'and execution is successful' do
      let(:recipe)                   { create(:recipe, user: user, step_classes: [rot_thirteen_step_class.to_s]) }
      specify do
        perform_execute_request(auth_headers, execution_params)

        expect(response.status).to eq(200)
      end
    end

    context 'and execution fails due to an error outside of the step' do
      let(:recipe)                   { create(:recipe, user: user, step_classes: [rot_thirteen_step_class.to_s]) }

      specify do
        perform_execute_request(auth_headers, execution_params.except(:input_files))

        expect(response.status).to eq(422)
        expect(body_as_json['errors']).to eq ["param is missing or the value is empty: input_files"]
      end
    end

    context 'and the recipe step class is not installed' do
      let(:nonexistent_step_class1)   { "NonExistentStepClass::NonsenseStep" }
      let(:nonexistent_step_class2)   { "NonExistentStepClass::RubbishStep" }

      let(:recipe)                   { create(:recipe, user: user, step_classes: [nonexistent_step_class1, nonexistent_step_class2]) }
      it 'sends back a meaningful error' do
        perform_execute_request(auth_headers, execution_params)

        expect(response.status).to eq(422)
        expect(body_as_json['errors']).to eq("The following steps are not installed: #{nonexistent_step_class1}, #{nonexistent_step_class2}. Check the spelling of the step class name, contact the system administrator to ask to install the step, or try with a different recipe.")
      end
    end
  end
  
  def perform_execute_request(auth_headers, data)
    execute_recipe_request(version, auth_headers, data)
  end
end