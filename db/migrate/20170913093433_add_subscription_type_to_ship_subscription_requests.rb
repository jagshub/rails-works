class AddSubscriptionTypeToShipSubscriptionRequests < ActiveRecord::Migration
  def change
    add_column :ship_subscription_requests, :subscription_type, :integer, default: 0, null: false
  end
end
