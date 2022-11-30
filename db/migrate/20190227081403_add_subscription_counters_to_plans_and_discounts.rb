class AddSubscriptionCountersToPlansAndDiscounts < ActiveRecord::Migration[5.0]
  def change
    add_column :payment_plans, :subscriptions_count, :integer, default: 0, null: false
    add_column :payment_discounts, :subscriptions_count, :integer, default: 0, null: false
  end
end
