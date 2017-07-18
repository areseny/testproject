require 'rails_helper'
require_relative 'version'

RSpec.describe Api::V1::StepClassController do

  let(:account)    { create(:account) }

  describe 'GET index' do
    before do
      allow(StepClassCollector).to receive(:step_classes).and_return(sample_step_classes)
    end

    specify do
      request_with_auth(account.new_jwt) do
        perform_step_class_index_request
      end

      expect(assigns(:available_step_classes)).to eq sample_step_json
    end
  end

  describe 'GET admin_index' do
    before do
      allow(StepClassCollector).to receive(:step_gems).and_return(sample_step_gems)
    end

    specify do
      request_with_auth(account.new_jwt) do
        perform_index_by_gems_request
      end

      expect(assigns(:step_gems)).to eq sample_gem_json
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

  def conversion_step_classes
    [
      InkStep::PandocConversionStep,
      InkStep::CalibreHtmlToEpubStep
    ]
  end

  def conversion_step_json
    [
        { name: InkStep::PandocConversionStep.name, description: InkStep::PandocConversionStep.description },
        { name: InkStep::CalibreHtmlToEpubStep.name, description: InkStep::CalibreHtmlToEpubStep.description }
    ]
  end

  def sample_step_gems
  [
      { name: "InkStep::Coko::DemoSteps", version: "1.2", git_version: "wat", repo: "some_repo", step_classes: sample_step_json},
      { name: "InkStep::Coko::ConversionSteps", version: '0.1', git_version: "ok", repo: "blah", step_classes: conversion_step_json}
    ]
  end

  def sample_gem_json
    sample_step_gems
  end

  def perform_step_class_index_request(data = {})
    get_index_request(version, data)
  end

  def perform_index_by_gems_request(data = {})
    get_index_by_gems_request(version, data)
  end
end
