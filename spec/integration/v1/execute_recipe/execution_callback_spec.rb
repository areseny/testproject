require 'rails_helper'
require_relative '../version'
require 'sidekiq/testing'

Sidekiq::Testing.inline!

describe "User executes a recipe and provides a callback URL" do

  # URL: /api/recipes/:id/execute
  # Method: POST
  # Execute a specific recipe belonging to the current user, providing a callback URL

  # curl -H "Content-Type: application/json, Accept: application/vnd.ink.v1, uid: user@example.com, auth_token: asdf" -X POST --form "input_file=@my-file.txt, callback_url=mysite.com/callback" http://localhost:3000/api/recipes/:id/execute

  describe "POST execute recipe" do

    let!(:user)             { create(:user, password: "password", password_confirmation: "password") }
    let!(:auth_headers)     { user.create_new_auth_token }
    let!(:html_file)        { fixture_file_upload('files/test.html', 'text/html') }

    let!(:recipe)           { create(:recipe, user: user) }

    let(:callback_url)     { "http://example.com/call_me_back" }

    let!(:execution_params) {
      {
          input_file: html_file,
          id: recipe.id,
          callback_url: callback_url
      }
    }

    let!(:rot13)      { "RotThirteenStep" }
    let!(:step)       { create(:recipe_step, recipe: recipe, position: 1, step_class_name: rot13) }

    before do
      stub_callback_request
    end

    context 'and execution is successful' do
      it 'posts to the callback' do
        perform_execute_request(auth_headers, execution_params)

        expect_callback_request
      end
    end

    context 'and execution fails' do
      let!(:process_step_spy)       { create(:process_step) }
      let!(:boobytrapped_step)      { RotThirteenStep.new(process_step: process_step_spy) }
      let(:step_spy)                { double(:rot_thirteen_step) }

      before do
        allow(ProcessStep).to receive(:new).and_return(process_step_spy)
        allow(RotThirteenStep).to receive(:new).and_return boobytrapped_step
        allow(boobytrapped_step).to receive(:perform_step) { raise "Oh noes! Error!" }
      end

      it 'sends the failed chain information back to the client' do
        perform_execute_request(auth_headers, execution_params)

        expect(response.status).to eq(200)

        expect_callback_request
      end
    end

    def expect_callback_request(body={}.to_json)
      expect(WebMock).to have_requested(:post, callback_url)
    end

    def stub_callback_request
      stub_request(:post, callback_url)
    end
  end
  
  def perform_execute_request(auth_headers, data)
    execute_recipe_request(version, auth_headers, data)
  end
end