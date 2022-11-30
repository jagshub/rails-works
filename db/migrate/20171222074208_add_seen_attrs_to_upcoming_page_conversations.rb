class AddSeenAttrsToUpcomingPageConversations < ActiveRecord::Migration[5.0]
  def change
    add_column :upcoming_page_conversations, :seen_at, :datetime, null: true
    add_column :upcoming_page_conversations, :last_message_sent_at, :datetime, null: true
  end
end
