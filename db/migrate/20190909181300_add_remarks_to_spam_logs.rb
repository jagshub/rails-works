class AddRemarksToSpamLogs < ActiveRecord::Migration[5.1]
  def change
    add_column :spam_logs, :remarks, :string, null: false
  end
end
