class AddParentLogIdToSpamLogs < ActiveRecord::Migration[5.1]
  def change
    safety_assured do
      add_column :spam_logs, :parent_log_id, :integer
      add_foreign_key :spam_logs, :spam_logs, column: :parent_log_id
    end
  end
end
