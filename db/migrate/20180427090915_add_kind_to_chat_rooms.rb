class AddKindToChatRooms < ActiveRecord::Migration[5.0]
  def change
    add_column :chat_rooms, :kind, :integer, null: false, default: 0
  end
end
