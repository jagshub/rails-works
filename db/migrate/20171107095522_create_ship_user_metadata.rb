class CreateShipUserMetadata < ActiveRecord::Migration[5.0]
  def change
    create_table :ship_user_metadata do |t|
      t.references :ship_instant_access_page, null: true
      t.references :user, index: false
      t.timestamps null: false
    end

    add_index :ship_user_metadata, :user_id, unique: true
    add_foreign_key :ship_user_metadata, :ship_instant_access_pages
    add_foreign_key :ship_user_metadata, :users
  end
end
