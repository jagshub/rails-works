class RemoveUnusedTables < ActiveRecord::Migration
  def change
    drop_table :user_dismissed_notice_associations
    drop_table :legacy_jobs
    drop_table :store_items
    drop_table :orders
    drop_table :addresses
    drop_table :subscriptions
    drop_table :plans
  end
end
