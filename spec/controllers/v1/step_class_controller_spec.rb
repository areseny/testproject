require 'rails_helper'
require_relative 'version'

RSpec.describe Api::V1::StepClassController do
  include Devise::Test::ControllerHelpers

  let(:user)    { create(:user) }

  describe 'GET index' do
    before do
      allow(StepClassCollector).to receive(:step_classes).and_return(sample_step_classes)
    end

    specify do
      request_with_auth(user.create_new_auth_token) do
        perform_step_class_index_request
      end

      expect(assigns(:step_classes)).to eq sample_step_classes
    end
  end

  def sample_step_classes
    [
      InkStep::ShoutifierStep,
      InkStep::RotThirteenStep
    ]
  end

  def perform_step_class_index_request(data = {})
    get_index_request(version, data)
  end
end
