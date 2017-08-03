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
      shoutifier_step_class,
      rot_thirteen_step_class
    ]
  end

  def sample_step_json
    [
        { name: shoutifier_step_class.name, description: shoutifier_step_class.description, accepted_parameters: shoutifier_step_class.accepted_parameters },
        { name: rot_thirteen_step_class.name, description: rot_thirteen_step_class.description, accepted_parameters: rot_thirteen_step_class.accepted_parameters }
    ]
  end

  def conversion_step_classes
    [
      pandoc_conversion_step_class,
      calibre_html_to_epub_step_class
    ]
  end

  def conversion_step_json
    [
        { name: pandoc_conversion_step_class.name, description: pandoc_conversion_step_class.description, accepted_parameters: pandoc_conversion_step_class.accepted_parameters },
        { name: calibre_html_to_epub_step_class.name, description: calibre_html_to_epub_step_class.description, accepted_parameters: calibre_html_to_epub_step_class.accepted_parameters }
    ]
  end

  def sample_step_gems
  [
      { name: "InkStep::Coko::DemoSteps", version: "1.2", git_version: "wat", repo: "some_repo", step_classes: sample_step_classes},
      { name: "InkStep::Coko::ConversionSteps", version: '0.1', git_version: "ok", repo: "blah", step_classes: conversion_step_classes}
    ]
  end

  def sample_gem_json
    [
        { name: "InkStep::Coko::DemoSteps", version: "1.2", git_version: "wat", repo: "some_repo", step_classes: sample_step_basic_json},
        { name: "InkStep::Coko::ConversionSteps", version: '0.1', git_version: "ok", repo: "blah", step_classes: conversion_step_basic_json}
    ]
  end

  def sample_step_basic_json
    [
        { name: shoutifier_step_class.name, description: shoutifier_step_class.description},
        { name: rot_thirteen_step_class.name, description: rot_thirteen_step_class.description}
    ]
  end

  def conversion_step_basic_json
    [
        { name: pandoc_conversion_step_class.name, description: pandoc_conversion_step_class.description},
        { name: calibre_html_to_epub_step_class.name, description: calibre_html_to_epub_step_class.description}
    ]
  end

  def perform_step_class_index_request(data = {})
    get_index_request(version, data)
  end

  def perform_index_by_gems_request(data = {})
    get_index_by_gems_request(version, data)
  end
end
