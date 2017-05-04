class CreateServices < ActiveRecord::Migration[5.0]
  def change
    create_table(:services) do |t|
      t.string :name, null: false
      t.string :description
      t.string :auth_key
      t.integer :account_id, null: false

      t.timestamps
    end

    add_index :services, :auth_key,     :unique => true
  end
end
