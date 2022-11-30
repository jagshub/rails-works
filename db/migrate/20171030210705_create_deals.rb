class CreateDeals < ActiveRecord::Migration[5.0]
  def change
    create_table :deals do |t|
      t.text :name, null: false
      t.text :slug, null: false
      t.jsonb :body, null: false
      t.uuid :image_uuid, null: false
      t.integer :price_cents, null: false, default: 0
      t.integer :normal_price_cents
      t.datetime :start_at
      t.datetime :end_at
      t.integer :product_id
      t.integer :state, null: false, default: 0

      t.timestamps
    end
  end
end
