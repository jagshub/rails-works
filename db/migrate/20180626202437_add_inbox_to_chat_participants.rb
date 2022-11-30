class AddInboxToChatParticipants < ActiveRecord::Migration[5.0]
  def change
    add_column :chat_participants, :inbox, :integer, default: 0
  end
end
