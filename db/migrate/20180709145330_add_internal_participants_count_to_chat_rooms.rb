class AddInternalParticipantsCountToChatRooms < ActiveRecord::Migration[5.0]
  def change
    add_column :chat_rooms, :internal_participants_count, :integer, default: 0, null: false
  end
end
