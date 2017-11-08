class AddRecipeStepPresets < ActiveRecord::Migration[5.0]
  def change
    create_table :recipe_step_presets do |t|
      t.string :name, null: false
      t.integer :recipe_step_id, null: false
      t.text :description
      t.json "execution_parameters", default: {}, null: false
      t.integer :account_id, null: false

      t.timestamps
    end
  end
end
