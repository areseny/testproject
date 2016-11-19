class RenameConversionStepToProcessStep < ActiveRecord::Migration[5.0]
  def change
    rename_table :conversion_steps, :process_steps
  end
end
