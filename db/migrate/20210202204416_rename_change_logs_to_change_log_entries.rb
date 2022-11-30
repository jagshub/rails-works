class RenameChangeLogsToChangeLogEntries < ActiveRecord::Migration[5.1]
  def change
    safety_assured {
      rename_table :change_logs, :change_log_entries
      add_column :change_log_entries, :major_update, :boolean, default: false, null: false
      add_column :change_log_entries, :create_discussion, :boolean, default: false, null: false
    }
  end
end
