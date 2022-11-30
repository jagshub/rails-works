class AddIndexToShipSubscriptionOnUserIdAndStatus < ActiveRecord::Migration[5.0]
  disable_ddl_transaction!

  def change
    add_index :ship_subscriptions, [:user_id, :status], algorithm: :concurrently
  end
end
