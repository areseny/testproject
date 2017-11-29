require "yaml"

class SingleStepExecutionSerializer < ActiveModel::Serializer
  attributes :id, :account_id, :description, :description, :slug, :notes, :execution_errors,
             :output_file_manifest, :input_file_manifest, :executed_at, :finished_at, :successful,
             :execution_parameters, :process_log_location, :errors

  def execution_parameters
    object.execution_parameters || {}
  end

  def process_log_location
    object.process_log_file_name
  end

  def executed_at
    object.executed_at.nil? ? nil : object.executed_at.iso8601
  end

  def finished_at
    object.finished_at.nil? ? nil : object.finished_at.iso8601
  end

  def execution_errors
    return "" if object.execution_errors.nil?
    errors = [YAML::load(object.execution_errors)].flatten
    errors.join(", ").gsub(/\n/, "")
  end

  def notes
    return "" if object.notes.nil?
    notes = [YAML::load(object.notes)].flatten
    notes.join(", ").gsub(/\n/, "")
  end

end
