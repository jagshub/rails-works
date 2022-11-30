class AddLastSeenAtToChatRoomParticipant < ActiveRecord::Migration[5.0]
  def change
    add_column :chat_participants, :last_seen_at, :datetime, null: true
  end
end
