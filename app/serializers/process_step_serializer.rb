require "yaml"

class ProcessStepSerializer < ActiveModel::Serializer
  attributes :id, :position, :process_chain_id, :step_class_name, :notes, :execution_errors,
             :output_file_path, :output_file_name, :version, :started_at, :finished_at

  def started_at
    object.started_at.nil? ? nil : object.started_at.iso8601
  end

  def finished_at
    object.finished_at.nil? ? nil : object.finished_at.iso8601
  end

  def successful
    object.execution_errors.blank?
  end

  def execution_errors
    return "" if object.execution_errors.nil?
    errors = YAML::load(object.execution_errors)
    errors.join(", ").gsub(/\n/, "")
  end

end
