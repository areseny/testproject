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

    let!(:account)          { create(:account) }
    let!(:auth_headers)     { account.new_jwt }

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
        shoutifier_step_class,
        rot_thirteen_step_class
    ]
  end

  def sample_step_json
    [
        { "name" => shoutifier_step_class.name, "description" => shoutifier_step_class.description, "accepted_parameters" => shoutifier_step_class.accepted_parameters },
        { "name" => rot_thirteen_step_class.name, "description" => rot_thirteen_step_class.description, "accepted_parameters" => rot_thirteen_step_class.accepted_parameters }
    ]
  end
  
  def perform_index_request(auth_headers, data = {})
    index_step_class_request(version, auth_headers)
  end
end