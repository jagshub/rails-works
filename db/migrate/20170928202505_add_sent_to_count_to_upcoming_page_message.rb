class AddSentToCountToUpcomingPageMessage < ActiveRecord::Migration
  def change
    add_column :upcoming_page_messages, :sent_to_count, :integer, null: false, default: 0
  end
end
