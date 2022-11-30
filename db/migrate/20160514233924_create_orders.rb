class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.integer :user_id, null: false
      t.uuid :uuid, null: false, default: 'gen_random_uuid()'
      t.integer :shipping_address_id, null: false
      t.integer :quantity, null: false
      t.integer :store_item_id, null: false
      t.string :remote_order_id
      t.string :remote_charge_id
      t.integer :base_total_cents, null: false, default: 0
      t.integer :tax_total_cents, null: false, default: 0
      t.integer :shipping_total_cents, null: false, default: 0
      t.integer :status, default: 0, null: false

      t.timestamps null: false
    end

    add_index :orders, :uuid, unique: true
  end
end
