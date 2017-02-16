require 'rails_helper'
require_relative '../version'
require 'sidekiq/testing'

Sidekiq::Testing.inline!

describe "User retrieves installed step classes" do

  # URL: /api/step_classes
  # Method: GET
  # Retrieve step classes installed on the server

  # curl -H "Content-Type: application/json, Accept: application/vnd.ink.v1, uid: user@example.com, auth_token: asdf" -X GET http://localhost:3000/api/step_classes

  describe "GET index" do

    let!(:user)             { create(:user) }
    let!(:auth_headers)     { user.create_new_auth_token }

    context 'get step classes without error' do
      specify do
        perform_index_request(auth_headers)

        expect(response.status).to eq(200)
      end
    end

    context 'serialise properly' do
      before do
        allow(StepClassCollector).to receive(:step_classes).and_return(sample_step_classes)
      end

      specify do
        perform_index_request(auth_headers)

        expect(response.status).to eq(200)
        expect(body_as_json['available_step_classes']).to match_array sample_step_classes.map(&:to_s)
      end
    end
  end

  def sample_step_classes
    [
        InkStep::ShoutifierStep,
        InkStep::RotThirteenStep
    ]
  end
  
  def perform_index_request(auth_headers, data = {})
    index_step_class_request(version, auth_headers)
  end
end