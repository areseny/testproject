class AddExecution < ActiveRecord::Migration

  def change

    create_table :executed_chains do |t|
      t.integer     :user_id, null: false
      t.datetime    :executed_at
      t.string      :input_file
      t.integer     :chain_template_id, null: false

      t.timestamps  null: false
    end

    create_table :conversion_steps do |t|
      t.integer     :executed_chain_id, null: false
      t.integer     :position, null: false
      t.integer     :step_class_id, null: false
      t.text        :notes
      t.datetime    :executed_at
      t.string      :output_file
      t.text        :conversion_errors

      t.timestamps  null: false
    end

    add_index :conversion_steps, [:position, :executed_chain_id], unique: true

  end

end
