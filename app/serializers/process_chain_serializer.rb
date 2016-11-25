require 'action_view'

class ProcessChainSerializer < ActiveModel::Serializer
  include ActionView::Helpers::DateHelper

  # has_many :process_steps

  attributes :id, :recipe_id, :successful, :executed_at, :executed_at_for_humans, :input_file_name,
             :input_file_path, :output_file_path, :output_file_name, :finished_at, :process_steps

  def process_steps
    object.process_steps.sort_by{ |step| step.position }.map{|step| ActiveModelSerializers::SerializableResource.new(step, adapter: :attribute).as_json}
  end

  def executed_at
    object.executed_at.nil? ? nil : object.executed_at.iso8601
  end

  def finished_at
    object.finished_at.nil? ? nil : object.finished_at.iso8601
  end

  def executed_at_for_humans
    return "" if object.executed_at.nil?
    "#{distance_of_time_in_words(object.executed_at, Time.now)} ago"
  end

  def successful
    object.successful?
  end

end