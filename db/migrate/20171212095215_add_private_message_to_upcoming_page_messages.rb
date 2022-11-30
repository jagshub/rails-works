class AddPrivateMessageToUpcomingPageMessages < ActiveRecord::Migration[5.0]
  def change
    add_column :upcoming_page_messages, :visibility, :integer, default: 0
  end
end
