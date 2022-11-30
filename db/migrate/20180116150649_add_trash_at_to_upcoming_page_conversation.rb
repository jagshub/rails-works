class AddTrashAtToUpcomingPageConversation < ActiveRecord::Migration[5.0]
  def change
    add_column :upcoming_page_conversations, :trashed_at, :datetime, null: true
    add_index :upcoming_page_conversations, :trashed_at
  end
end
