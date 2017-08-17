require "yaml"

class ProcessStepSerializer < ActiveModel::Serializer
  attributes :id, :position, :process_chain_id, :step_class_name, :notes, :execution_errors,
             :output_file_manifest, :version, :started_at, :finished_at, :successful,
             :execution_parameters, :process_log, :process_log_location

  def execution_parameters
    object.execution_parameters || {}
  end

  def process_log_location
    object.process_log_file_name
  end

  def started_at
    object.started_at.nil? ? nil : object.started_at.iso8601
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

  def process_log
    return "" if object.process_log.nil?
    log_contents = [YAML::load(object.process_log)].flatten
    log_contents.join(", ").gsub(/\n/, "")
  end

end
