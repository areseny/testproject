class RemoveStepClass < ActiveRecord::Migration
  def up
    change_column_null :recipe_steps, :step_class_name, false
    change_column_null :conversion_steps, :step_class_name, false
    remove_column :recipe_steps, :step_class_id, :integer
    remove_column :conversion_steps, :step_class_id, :integer
    drop_table :step_classes
  end

  def down
    change_column_null :recipe_steps, :step_class_name, true
    change_column_null :conversion_steps, :step_class_name, true
    add_column :recipe_steps, :step_class_id, :integer
    add_column :conversion_steps, :step_class_id, :integer

    create_table "step_classes", force: :cascade do |t|
      t.string   "name",
      t.timestamps
    end
  end
end
