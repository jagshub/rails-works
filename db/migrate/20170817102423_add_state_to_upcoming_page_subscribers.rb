class AddStateToUpcomingPageSubscribers < ActiveRecord::Migration
  def change
    add_column :upcoming_page_subscribers, :state, :integer, default: 0, null: false
  end
end
