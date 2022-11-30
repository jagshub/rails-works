class AddFalsePositiveToSpamLogs < ActiveRecord::Migration[5.1]
  def change
    safety_assured { add_column :spam_logs, :false_positive, :boolean, default: false, null: false }
  end
end
