class DropChatGuests < ActiveRecord::Migration[5.1]
  def change
    drop_table :chat_guests
  end
end
