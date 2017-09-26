class RecipeStepSerializer < ActiveModel::Serializer
  attributes :id, :position, :recipe_id, :step_class_name, :description, :execution_parameters, :human_readable_name,
             :default_parameter_values, :required_parameters, :accepted_parameters

  has_many :recipe_step_presets do
    if scope.admin?
      object.recipe_step_presets
    else
      object.recipe_step_presets.where(account_id: scope.account.id)
    end
  end

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

  def default_parameter_values
    if object.step_class.nil?
      nil
    else
      object.step_class.default_parameter_values
    end
  end

  def required_parameters
    if object.step_class.nil?
      nil
    else
      object.step_class.required_parameters
    end
  end

  def accepted_parameters
    if object.step_class.nil?
      nil
    else
      object.step_class.accepted_parameters
    end
  end
end
