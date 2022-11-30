class ChangeActionAndLevelOnSpamLogs < ActiveRecord::Migration[5.1]
  def change
    safety_assured do
      change_column :spam_logs, :level, :integer, null: false
      change_column :spam_logs, :action, :string, null: false
    end
  end
end
