class RecipeStepSerializer < ActiveModel::Serializer
  attributes :id, :position, :recipe_id, :step_class_name

end
