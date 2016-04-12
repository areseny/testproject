require 'action_view'

class ConversionChainSerializer < ActiveModel::Serializer
  include ActionView::Helpers::DateHelper

  has_many :conversion_steps

  attributes :id, :recipe_id, :successful, :executed_at, :executed_at_for_humans, :input_file_name, :input_file_path, :output_file_path

  def executed_at
    object.executed_at.strftime("%d %B, %Y %l:%M %P %Z")
  end

  def executed_at_for_humans
    "#{distance_of_time_in_words(object.executed_at, Time.now)} ago"
  end

  def successful
    object.successful?
  end

end