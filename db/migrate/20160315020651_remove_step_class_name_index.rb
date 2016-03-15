class RemoveStepClassNameIndex < ActiveRecord::Migration
  def change
    remove_index :step_classes, name: 'index_step_classes_on_name'
  end
end
