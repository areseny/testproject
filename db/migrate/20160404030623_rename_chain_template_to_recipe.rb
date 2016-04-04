class RenameChainTemplateToRecipe < ActiveRecord::Migration
  def change
    rename_table :chain_templates, :recipes
    rename_column :conversion_chains, :chain_template_id, :recipe_id
    rename_column :step_templates, :chain_template_id, :recipe_id
  end
end
