class RenameOutputFileManifest < ActiveRecord::Migration[5.0]
  def change
    rename_column :process_chains, :input_file_manifest, :input_file_list
    rename_column :process_steps, :output_file_manifest, :output_file_list
  end
end
