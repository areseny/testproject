class AddVersionToConversionStep < ActiveRecord::Migration
  def change
    add_column :conversion_steps, :version, :string
  end
end
