class AddGroupedNotificationsIndex < ActiveRecord::Migration
  def up
    # Avoid wrapping transaction (CONCURRENTLY can't run inside transactions)
    execute 'commit;'

    add_index :notifications, [:user_id, :id], algorithm: :concurrently
    execute "DROP INDEX CONCURRENTLY index_notifications_on_user_id"

    # Start a new transaction so Rails doesn't get confused
    execute 'begin;'
  end

  def down
    add_index :notifications, :user_id
    remove_index :notifications, [:user_id, :id]
  end
end
