class AddChatPreferencesToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :chat_preferences, :integer, default: 0, null: false
  end
end
