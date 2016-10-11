require "yaml"

class ConversionStepSerializer < ActiveModel::Serializer
  attributes :id, :position, :conversion_chain_id, :step_class_name, :notes, :executed_at, :execution_errors, :output_file_path, :output_file_name

  def successful
    object.execution_errors.blank?
  end

  def execution_errors
    return nil if object.execution_errors.nil?
    YAML::load(object.execution_errors).join(", ")
  end

  def executed_at
    object.created_at
  end

end
