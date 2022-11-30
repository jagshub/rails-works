class AddTextHtmlToChatMessages < ActiveRecord::Migration[5.0]
  def change
    add_column :chat_messages, :text_html, :text
  end
end
