class AddDescriptionToStepClass < ActiveRecord::Migration
  def change
    add_column :step_classes, :description, :string
  end
end
