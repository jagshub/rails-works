class AddUserSyncFields < ActiveRecord::Migration
  disable_ddl_transaction!

  def change
    add_column :users, :last_friend_sync_at, :timestamp, null: true

    reversible do |d|
      d.up do
        execute 'UPDATE users SET last_friend_sync_at = last_twitter_sync_at WHERE last_twitter_sync_at IS NOT NULL AND last_twitter_sync_error IS NULL'
      end
    end
  end
end
