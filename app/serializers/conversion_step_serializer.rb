require "yaml"

class ConversionStepSerializer < ActiveModel::Serializer
  attributes :id, :position, :process_chain_id, :step_class_name, :notes, :executed_at, :execution_errors, :output_file_path, :output_file_name, :version

  def successful
    object.execution_errors.blank?
  end

  def execution_errors
    return "" if object.execution_errors.nil?
    errors = YAML::load(object.execution_errors)
    errors.join(", ").gsub(/\n/, "")
  end

  def executed_at
    object.created_at
  end

end
