class AddIndexToFeedPosts < ActiveRecord::Migration
  disable_ddl_transaction!

  def change
    add_index :collection_subscriptions, [:user_id, :state], algorithm: :concurrently
    add_index :subscriptions, [:subject_type, :subscriber_id], algorithm: :concurrently 
  end
end
