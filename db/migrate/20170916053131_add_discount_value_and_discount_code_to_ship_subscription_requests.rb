class AddDiscountValueAndDiscountCodeToShipSubscriptionRequests < ActiveRecord::Migration
  def change
    add_column :ship_subscription_requests, :discount_value, :integer, null: true
    add_column :ship_subscription_requests, :invite_code, :string, null: true
  end
end
