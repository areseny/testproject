class AddPublicFlagToRecipe < ActiveRecord::Migration
  def change
    add_column :recipes, :public, :boolean, default: false, null: false
  end
end
