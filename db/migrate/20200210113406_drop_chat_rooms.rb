class DropChatRooms < ActiveRecord::Migration[5.1]
  def change
    drop_table 'chat_rooms'
  end
end
