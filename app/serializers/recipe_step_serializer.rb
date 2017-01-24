class RecipeStepSerializer < ActiveModel::Serializer
  attributes :id, :position, :recipe_id, :step_class_name, :description

  def description
    if object.step_class.nil?
      nil
    else
      object.step_class.description
    end
  end

end
