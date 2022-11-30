class AddPaymentDiscountToPaymentSubscriptions < ActiveRecord::Migration[5.0]
  def change
    change_table :payment_subscriptions do |t|
      t.belongs_to :discount, index: true
    end

    add_foreign_key :payment_subscriptions, :payment_discounts, column: :discount_id
  end
end
