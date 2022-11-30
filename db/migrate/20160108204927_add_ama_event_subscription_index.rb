class AddAmaEventSubscriptionIndex < ActiveRecord::Migration
  disable_ddl_transaction!

  def change
    add_index :ama_event_subscriptions, :ama_event_id, algorithm: :concurrently
  end
end
