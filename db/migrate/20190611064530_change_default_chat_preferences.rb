class ChangeDefaultChatPreferences < ActiveRecord::Migration[5.1]
  def change
    change_column_default :users, :chat_preferences, from: 0, to: 100
  end
end
