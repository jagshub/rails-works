class RemoveUpdatedAtFromNotificationLog < ActiveRecord::Migration
  def up
    remove_column :notification_logs, :updated_at
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
