class AddLeftAtToChatParticipants < ActiveRecord::Migration[5.0]
  def change
    add_column :chat_participants, :status, :integer, default: 0, null: false
    add_column :chat_participants, :left_at, :datetime, null: true
    add_column :chat_participants, :banned_at, :datetime, null: true
  end
end
