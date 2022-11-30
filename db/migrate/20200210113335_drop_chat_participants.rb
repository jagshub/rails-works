class DropChatParticipants < ActiveRecord::Migration[5.1]
  def change
    drop_table 'chat_participants'
  end
end
