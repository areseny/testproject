class CreateChainTemplate < ActiveRecord::Migration
  def change
    create_table :chain_templates do |t|
      t.integer     :user_id, null: false
      t.string      :name, null: false
      t.text        :description
      t.boolean     :active, null: false, default: true

      t.timestamps  null: false
    end
  end
end
