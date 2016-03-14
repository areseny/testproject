class RenameExecutedChainToConversionChain < ActiveRecord::Migration
  def change
    remove_index :conversion_steps, :column => [:position, :executed_chain_id]
    rename_table :executed_chains, :conversion_chains
    rename_column :conversion_steps, :executed_chain_id, :conversion_chain_id
    add_index :conversion_steps, [:position, :conversion_chain_id], name: "index_conversion_steps_on_position_and_conversion_chain_id", unique: true

  end
end
