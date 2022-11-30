class AddNotificationFlagToChangeLogEntries < ActiveRecord::Migration[5.1]
  def change
    safety_assured {
      add_column :change_log_entries, :notification_sent, :boolean, default: false, null: false
    }
  end
end
