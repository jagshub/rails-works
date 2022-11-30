class CreateSuperPeers < ActiveRecord::Migration[5.1]
  def change
    create_table :super_peers do |t|
      t.string :name, null: false
      t.string :title, null: false
      t.string :bio, null: false
      t.string :photo_uuid, null: false
      t.string :super_peer_link, null: false
      t.integer :priority, null: false, default: 0
      t.datetime :trashed_at, null: true

      t.timestamps
    end
  end
end
