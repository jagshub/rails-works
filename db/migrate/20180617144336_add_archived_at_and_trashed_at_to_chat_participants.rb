class AddArchivedAtAndTrashedAtToChatParticipants < ActiveRecord::Migration[5.0]
  def change
    add_column :chat_participants, :trashed_at, :datetime, null: true
    add_column :chat_participants, :archived, :boolean, null: false, default: false
  end
end
