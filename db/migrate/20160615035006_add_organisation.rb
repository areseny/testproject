class AddOrganisation < ActiveRecord::Migration
  def change
  	create_table :organisations do |t|
  		t.string 		:name, null: false
  		t.string 		:description
  		t.timestamps 	null: false
  	end

  	create_table :memberships do |t|
  		t.integer :organisation_id, null: false
  		t.integer :user_id, null: false
  		t.boolean :admin, default: false, null: false
  		t.timestamps null: false
  	end
  	add_index :organisations, :name, :unique => true
  	add_index :memberships, [:organisation_id, :user_id], :unique => true
  
  end
end
