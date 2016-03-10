class AddStepTemplates < ActiveRecord::Migration
  def change

    create_table :step_templates do |t|
      t.integer     :chain_template_id, null: false
      t.integer     :step_class_id, null: false
      t.integer     :position, null: false

      t.timestamps  null: false
    end

    create_table :step_classes do |t|
      t.string      :name, null: false
      t.boolean     :active, null: false, default: true

      t.timestamps  null: false
    end

    add_index :step_templates, [:chain_template_id, :position], unique: true, name: 'chain_step_position_index'
    add_index :step_classes, :name, unique: true

  end
end
