class DropChatMessages < ActiveRecord::Migration[5.1]
  def change
    drop_table 'chat_messages'
  end
end
