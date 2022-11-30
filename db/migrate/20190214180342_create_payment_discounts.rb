class CreatePaymentDiscounts < ActiveRecord::Migration[5.0]
  def change
    create_table :payment_discounts do |t|
      t.boolean :active, null: false, default: false

      t.integer :percentage_off, null: false

      t.string :name, null: false
      t.string :stripe_coupon_code, null: false
      t.string :code, null: false
      t.text :description

      t.timestamps null: false
    end

    add_index :payment_discounts, :stripe_coupon_code, unique: true
    add_index :payment_discounts, :code, unique: true
    add_index :payment_discounts, :active, where: 'active is true'
  end
end
