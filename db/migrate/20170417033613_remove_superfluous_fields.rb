class RemoveSuperfluousFields < ActiveRecord::Migration[5.0]
  def change
    remove_column :process_chains, :input_file
    remove_column :process_steps, :output_file
  end
end
