require 'action_view'

class ConversionChainSerializer < ActiveModel::Serializer
  include ActionView::Helpers::DateHelper

  # has_many :conversion_steps

  attributes :id, :recipe_id, :successful, :executed_at, :executed_at_for_humans, :input_file_name, :input_file_path, :output_file_path, :output_file_name, :finished_at, :conversion_steps

  def conversion_steps
    object.conversion_steps.sort_by{ |step| step.position }
  end

  def executed_at
    object.executed_at.nil? ? nil : object.executed_at.iso8601
  end

  def executed_at_for_humans
    return "" if object.executed_at.nil?
    "#{distance_of_time_in_words(object.executed_at, Time.now)} ago"
  end

  def successful
    object.successful?
  end

end