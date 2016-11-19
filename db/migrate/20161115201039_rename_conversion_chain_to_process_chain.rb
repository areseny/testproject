class RenameConversionChainToProcessChain < ActiveRecord::Migration[5.0]
  def change
    rename_table :conversion_chains, :process_chains
    rename_column :conversion_steps, :conversion_chain_id, :process_chain_id
  end
end
