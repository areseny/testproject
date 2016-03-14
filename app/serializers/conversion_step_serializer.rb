class ConversionStepSerializer < ActiveModel::Serializer
  attributes :id, :position, :conversion_chain_id, :step_class_name, :notes, :executed_at, :conversion_errors

end
