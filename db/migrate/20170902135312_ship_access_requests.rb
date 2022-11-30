class ShipAccessRequests < ActiveRecord::Migration
  def change
    create_table :ship_access_requests do |t|
      t.boolean :shared_on_twitter, default: false, null: false
      t.boolean :shared_on_facebook, default: false, null: false
      t.references :user, unique: true, null: false
      t.integer :inviter_id, null: true
      t.timestamps null: false
    end

    add_index :ship_access_requests, :inviter_id
  end
end
