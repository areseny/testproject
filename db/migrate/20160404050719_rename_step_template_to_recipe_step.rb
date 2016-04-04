class RenameStepTemplateToRecipeStep < ActiveRecord::Migration
  def change
    rename_table :step_templates, :recipe_steps
  end
end
