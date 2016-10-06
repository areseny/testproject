class AddStepClassNameToRecipeSteps < ActiveRecord::Migration
  def up
    add_column :recipe_steps, :step_class_name, :string

    RecipeStep.reset_column_information
    StepClass.reset_column_information

    RecipeStep.all.each do |step|
      ap "Changing step #{step.step_class.name}"
      step.update_attribute(:step_class_name, "InkStep::#{step.step_class.name}")
      ap "now changed to #{step.reload.step_class_name}"
    end
  end

  def down
    remove_column :recipe_steps, :step_class_name
  end
end

class RecipeStep < ActiveRecord::Base
  belongs_to :step_class
end

class StepClass < ActiveRecord::Base

end