class CreateUpcomingEvents < ActiveRecord::Migration[6.1]
  def change
    create_table :upcoming_events do |t|
      t.references :product, null: false, index: false
      t.references :post, null: true, index: false
      t.references :user, null: false

      t.string :title, null: false
      t.string :description, null: true
      t.string :banner_uuid, null: true
      t.timestamp :confirmed_at, null: true

      t.timestamps null: false
    end

    add_index :upcoming_events, [:product_id, :post_id], unique: true
  end
end
