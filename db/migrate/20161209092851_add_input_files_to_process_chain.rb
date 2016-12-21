class AddInputFilesToProcessChain < ActiveRecord::Migration[5.0]
  def change
    add_column :process_chains, :input_file_manifest, :text
    add_column :process_steps, :output_file_manifest, :text
  end
end
