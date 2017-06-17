class AddExecutionParametersToRecipeStep < ActiveRecord::Migration[5.0]
  def change
    add_column :recipe_steps, :execution_parameters, :json, null: false, default: {}
  end
end
