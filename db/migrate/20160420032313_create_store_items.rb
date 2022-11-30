class CreateStoreItems < ActiveRecord::Migration
  def change
    create_table :store_items do |t|
      t.integer :merchant_access_token_id, null: false
      t.integer :post_id, null: false
      t.string :sku, null: false, unique: true
      t.integer :base_price_cents, null: false, default: 0
      t.integer :inventory_count, default: 0, null: false
      t.float :application_fee_percentage, default: 0, null: false
      t.string :shipping_method_text, null: false
      t.string :expected_ship_by_text, null: false
      t.string :customer_service_text, null: false

      t.timestamps null: false
    end
  end
end
