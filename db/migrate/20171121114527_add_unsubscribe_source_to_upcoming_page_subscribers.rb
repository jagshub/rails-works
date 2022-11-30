class AddUnsubscribeSourceToUpcomingPageSubscribers < ActiveRecord::Migration[5.0]
  def change
    add_column :upcoming_page_subscribers, :unsubscribe_source, :string, null: true
  end
end
