class ChangeActionOnSpamLogsToInteger < ActiveRecord::Migration[5.1]
  def change
    safety_assured do
      change_column :spam_logs, :action, 'integer USING CAST(action AS integer)'
    end
  end
end
