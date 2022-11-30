class RemoveShipSubscriptionRequests < ActiveRecord::Migration[5.0]
  def change
    drop_table :ship_subscription_requests
  end
end
