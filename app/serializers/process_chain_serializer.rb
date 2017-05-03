require 'action_view'

class ProcessChainSerializer < ActiveModel::Serializer
  include ActionView::Helpers::DateHelper

  has_many :process_steps, serializer: ProcessStepSerializer

  attributes :id, :recipe_id, :executed_at, :finished_at, :process_steps, :created_at, :input_file_manifest, :output_file_manifest

  def executed_at
    object.executed_at.nil? ? nil : object.executed_at.iso8601
  end

  def finished_at
    object.finished_at.nil? ? nil : object.finished_at.iso8601
  end

end