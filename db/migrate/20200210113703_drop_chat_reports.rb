class DropChatReports < ActiveRecord::Migration[5.1]
  def change
    drop_table 'chat_reports'
  end
end
