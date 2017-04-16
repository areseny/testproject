require 'rails_helper'
require_relative 'version'

RSpec.describe Api::V1::StepClassController do
  include Devise::Test::ControllerHelpers

  let(:account)    { create(:account) }

  describe 'GET index' do
    before do
      allow(StepClassCollector).to receive(:step_classes).and_return(sample_step_json)
    end

    specify do
      request_with_auth(account.create_new_auth_token) do
        perform_step_class_index_request
      end

      expect(assigns(:step_classes)).to eq sample_step_classes.map{|klass| { name: klass.name, description: klass.description } }
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
        { name: InkStep::ShoutifierStep.name, description: InkStep::ShoutifierStep.description },
        { name: InkStep::RotThirteenStep.name, description: InkStep::RotThirteenStep.description }
    ]
  end

  def perform_step_class_index_request(data = {})
    get_index_request(version, data)
  end
end
