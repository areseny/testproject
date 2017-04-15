class RenameUserToAccount < ActiveRecord::Migration[5.0]
  def change
    rename_column :recipes, :user_id, :account_id
    rename_column :process_chains, :user_id, :account_id
    rename_column :user_roles, :user_id, :account_id

    rename_table :users, :accounts
    rename_table :user_roles, :account_roles
  end
end
