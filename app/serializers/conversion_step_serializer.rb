require "yaml"

class ConversionStepSerializer < ActiveModel::Serializer
  attributes :id, :position, :conversion_chain_id, :step_class_name, :notes, :executed_at, :conversion_errors

  def successful
    object.conversion_errors.blank?
  end

  def conversion_errors
    return nil if object.conversion_errors.nil?
    YAML::load(object.conversion_errors).join(", ")
  end

  def executed_at
    object.created_at
  end

end
