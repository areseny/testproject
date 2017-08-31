class CreateRecipeFavourites < ActiveRecord::Migration[5.0]
  def change
    create_table :recipe_favourites do |t|
      t.integer :account_id, null: false
      t.integer :recipe_id, null: false

      t.timestamps
    end

    add_index :recipe_favourites, [:account_id, :recipe_id]
  end
end
