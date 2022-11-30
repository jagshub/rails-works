class AddStripeSubscriptionIdToShipSubscriptions < ActiveRecord::Migration
  def change
    add_column :ship_subscriptions, :stripe_subscription_id, :string
  end
end
