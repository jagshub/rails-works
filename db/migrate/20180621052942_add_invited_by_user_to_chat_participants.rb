class AddInvitedByUserToChatParticipants < ActiveRecord::Migration[5.0]
  def change
    add_column :chat_participants, :invited_by_user_id, :integer, null: true
  end
end
