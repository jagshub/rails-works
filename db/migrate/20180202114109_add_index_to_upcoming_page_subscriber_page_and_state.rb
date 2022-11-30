class AddIndexToUpcomingPageSubscriberPageAndState < ActiveRecord::Migration[5.0]
  disable_ddl_transaction!

  def change
    add_index :upcoming_page_subscribers, %i(upcoming_page_id state), algorithm: :concurrently
  end
end
