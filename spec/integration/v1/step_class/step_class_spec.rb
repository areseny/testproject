require 'rails_helper'
require_relative '../version'
require 'sidekiq/testing'

Sidekiq::Testing.inline!

describe "Account retrieves installed step classes" do

  # URL: /api/step_classes
  # Method: GET
  # Retrieve step classes installed on the server

  # curl -H "Content-Type: application/json, Accept: application/vnd.ink.v1, uid: account@example.com, auth_token: asdf" -X GET http://localhost:3000/api/step_classes

  describe "GET index" do

    let!(:account)             { create(:account) }
    let!(:auth_headers)     { account.create_new_auth_token }

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
        expect(body_as_json['available_step_classes']).to match_array sample_step_json
      end
    end
  end

  def sample_step_classes
    [
        InkStep::ShoutifierStep,
        InkStep::RotThirteenStep
    ]
  end

  def sample_step_json
    [
        { "name" => InkStep::ShoutifierStep.name, "description" => InkStep::ShoutifierStep.description },
        { "name" => InkStep::RotThirteenStep.name, "description" => InkStep::RotThirteenStep.description }
    ]
  end
  
  def perform_index_request(auth_headers, data = {})
    index_step_class_request(version, auth_headers)
  end
end