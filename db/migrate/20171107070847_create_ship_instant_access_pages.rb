class CreateShipInstantAccessPages < ActiveRecord::Migration[5.0]
  def change
    create_table :ship_instant_access_pages do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :text, null: true
      t.references :ship_invite_code, null: true
      t.datetime :trashed_at, null: true
      t.timestamps null: false
    end

    add_foreign_key :ship_instant_access_pages, :ship_invite_codes
  end
end
