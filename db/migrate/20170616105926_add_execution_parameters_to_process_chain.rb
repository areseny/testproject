class AddExecutionParametersToProcessChain < ActiveRecord::Migration[5.0]
  def change
    add_column :process_chains, :execution_parameters, :json, null: false, default: {}
  end
end
