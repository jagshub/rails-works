class AddReplyToToUpcomingPageMessages < ActiveRecord::Migration
  def change
    add_column :upcoming_page_messages, :reply_to, :string
  end
end
