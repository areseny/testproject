class UserRole < ActiveRecord::Migration[5.0]
  def change
    create_table :user_roles do |t|
      t.integer :user_id, null: false
      t.string :role, null: false
    end

    add_index :user_roles, [:user_id, :role]
  end

end
