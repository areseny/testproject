require 'rails_helper'
require_relative '../version'
require 'sidekiq/testing'

Sidekiq::Testing.inline!

describe "User executes a ROT13 recipe" do

  # URL: /api/recipes/:id/execute
  # Method: GET
  # Execute a specific recipe belonging to the current user

  # curl -H "Content-Type: application/json, Accept: application/vnd.ink.v1, uid: user@example.com, auth_token: asdf" -X GET http://localhost:3000/api/recipes/:id/execute

  let!(:user)             { create(:user, password: "password", password_confirmation: "password") }
  let!(:auth_headers)     { user.create_new_auth_token }
  let!(:text_file)        { fixture_file_upload('files/plaintext.txt', 'text/plain') }

  let!(:recipe)           { create(:recipe, user: user) }


  let!(:step_class)       { "RotThirteenStep" }
  let!(:step1)            { create(:recipe_step, recipe: recipe, position: 1, step_class_name: step_class) }

  context 'if the execution is successful' do
    let!(:execution_params) {
      {
          input_file: text_file,
          id: recipe.id
      }
    }

    before do
      perform_execute_request(auth_headers, execution_params)
    end

    it 'is successful' do
      expect(response.status).to eq(200)
      expect(body_as_json['process_chain']).to_not be_nil
      expect(body_as_json['process_chain']['process_steps'].count).to eq 1
      body_as_json['process_chain']['process_steps'].map do |s|
        expect(s['execution_errors']).to eq ""
      end
      # expect(body_as_json['process_chain']['process_steps'].sort_by{|e| e['position'].to_i}.map{|e| e['output_file_path']}).to eq [true, true]
    end

    it 'has an expected output file' do
      result = ProcessChain.last.output_file
      expect(result.read).to eq "Guvf vf fbzr grkg."
    end
  end

  context 'if the execution fails' do
    let!(:step_spy)           { create(:process_step, step_class_name: "RotThirteenStep") }
    let!(:photo_file)         { fixture_file_upload('files/kitty.jpeg', 'image/jpeg') }
    let!(:boobytrapped_step)  { RotThirteenStep.new(process_step: step_spy) }

    let!(:execution_params) {
      {
          input_file: photo_file,
          id: recipe.id
      }
    }

    before do
      allow(ProcessStep).to receive(:new).and_return(step_spy)
      expect(boobytrapped_step).to receive(:perform_step) { raise "OMG!" }
      expect(RotThirteenStep).to receive(:new).and_return(boobytrapped_step)
    end

    it 'fails nicely' do
      perform_execute_request(auth_headers, execution_params)

      result = step_spy.output_file
      expect(result.file).to be_nil
    end
  end

  def perform_execute_request(auth_headers, data)
    execute_recipe_request(version, auth_headers, data)
  end
end