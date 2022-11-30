class AddUserIdIndexToUpcomingPageSubscribers < ActiveRecord::Migration
  disable_ddl_transaction!

  def change
    add_index :upcoming_page_subscribers, :user_id, algorithm: :concurrently
  end
end
