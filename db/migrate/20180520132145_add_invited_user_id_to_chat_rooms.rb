class AddInvitedUserIdToChatRooms < ActiveRecord::Migration[5.0]
  def change
    add_column :chat_rooms, :invited_user_id, :integer, null: true
  end
end
