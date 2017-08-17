class AddLogToProcessStep < ActiveRecord::Migration[5.0]
  def change
    add_column :process_steps, :process_log, :text, null: false, default: ""
  end
end
