class AddCountersToChatRooms < ActiveRecord::Migration[5.0]
  def change
    add_column :chat_rooms, :participants_count, :integer, null: false, default: 0
  end
end
