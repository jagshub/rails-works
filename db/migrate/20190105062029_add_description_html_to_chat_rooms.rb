class AddDescriptionHtmlToChatRooms < ActiveRecord::Migration[5.0]
  def change
    add_column :chat_rooms, :description_html, :text
  end
end
