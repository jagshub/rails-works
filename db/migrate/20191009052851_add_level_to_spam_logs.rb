class AddLevelToSpamLogs < ActiveRecord::Migration[5.1]
  def change
    add_column :spam_logs, :level, :integer
  end
end
