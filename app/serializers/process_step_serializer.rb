require "yaml"

class ProcessStepSerializer < ActiveModel::Serializer
  attributes :id, :position, :process_chain_id, :step_class_name, :notes, :execution_errors,
             :output_file_manifest, :version, :started_at, :finished_at, :successful

  def started_at
    object.started_at.nil? ? nil : object.started_at.iso8601
  end

  def finished_at
    object.finished_at.nil? ? nil : object.finished_at.iso8601
  end

  def execution_errors
    return "" if object.execution_errors.nil?
    errors = YAML::load(object.execution_errors)
    errors.join(", ").gsub(/\n/, "")
  end

end
