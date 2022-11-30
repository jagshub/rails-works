class FixTwitterVerifiedIndex < ActiveRecord::Migration
  disable_ddl_transaction!

  def change
    remove_index :twitter_verified_users, :twitter_username
    execute 'CREATE INDEX CONCURRENTLY ON twitter_verified_users(lower(twitter_username))'
  end
end
