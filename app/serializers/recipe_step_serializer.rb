class RecipeStepSerializer < ActiveModel::Serializer
  attributes :id, :position, :recipe_id, :step_class_name, :description, :execution_parameters, :human_readable_name

  def execution_parameters
    object.execution_parameters || {}
  end

  def description
    if object.step_class.nil?
      nil
    else
      object.step_class.description
    end
  end

  def human_readable_name
    if object.step_class.nil?
      nil
    else
      object.step_class.human_readable_name
    end
  end
end
