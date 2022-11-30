class AddParentChatMessageIdToChatMessages < ActiveRecord::Migration[5.0]
  def change
    add_column :chat_messages, :parent_chat_message_id, :integer, null: true
    add_foreign_key :chat_messages, :chat_messages, column: :parent_chat_message_id
  end
end
