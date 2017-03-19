require 'action_view'

class ProcessChainSerializer < ActiveModel::Serializer
  include ActionView::Helpers::DateHelper

  # has_many :process_steps

  attributes :id, :recipe_id, :executed_at, :finished_at, :process_steps, :created_at, :input_file_manifest, :output_file_manifest

  def process_steps
    object.process_steps.sort_by{ |step| step.position }.map{|step| ActiveModelSerializers::SerializableResource.new(step, adapter: :attribute).as_json}
  end

  def executed_at
    object.executed_at.nil? ? nil : object.executed_at.iso8601
  end

  def finished_at
    object.finished_at.nil? ? nil : object.finished_at.iso8601
  end

end