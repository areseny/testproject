class AddExecutionParametersToProcessStep < ActiveRecord::Migration[5.0]
  def change
    add_column :process_steps, :execution_parameters, :json, null: false, default: {}
  end
end
