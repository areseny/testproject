class RenameConversionErrorsToExecutionErrorsOnConversionStep < ActiveRecord::Migration
  def change
    rename_column :conversion_steps, :conversion_errors, :execution_errors
  end
end
