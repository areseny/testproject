class CreateSingleStepExecution < ActiveRecord::Migration[5.0]
  def change
    create_table :single_step_executions do |t|
      t.integer :account_id
      t.string :description
      t.string :slug
      t.string :step_class_name

      t.json :execution_parameters, default: {}, null: false
      t.datetime :executed_at
      t.datetime :finished_at

      t.text :input_file_list
      t.text :output_file_list
      t.boolean :successful
      t.text :notes
      t.text :execution_errors
      t.text :process_log,          default: "", null: false

      t.timestamps
    end
  end
end
