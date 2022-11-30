class RemoveLowerUsernameIndex < ActiveRecord::Migration
  disable_ddl_transaction!

  def up
    execute 'DROP INDEX CONCURRENTLY index_users_on_username_lower'
  end

  def down
    execute 'CREATE INDEX CONCURRENTLY index_users_on_username_lower ON users(lower(username))'
  end
end
