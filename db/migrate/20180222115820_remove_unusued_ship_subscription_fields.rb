class RemoveUnusuedShipSubscriptionFields < ActiveRecord::Migration[5.0]
  def change
    remove_column :ship_subscriptions, :started_at
    remove_column :ship_subscriptions, :stopped_at
    remove_column :ship_subscriptions, :trial_ends_at
  end
end
