class RecipeStepSerializer < ActiveModel::Serializer
  attributes :id, :position, :recipe_id, :step_class_name, :step_class_description

  def step_class_name
    object.step_class.name
  end

  def step_class_description
    object.step_class.description
  end

end
