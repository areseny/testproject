class StepTemplateSerializer < ActiveModel::Serializer
  attributes :id, :position, :chain_template_id, :step_class_name

  def step_class_name
    object.step_class.name
  end

end
