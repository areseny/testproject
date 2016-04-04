class StepTemplateSerializer < ActiveModel::Serializer
  attributes :id, :position, :recipe_id, :step_class_name

  def step_class_name
    object.step_class.name
  end

end
