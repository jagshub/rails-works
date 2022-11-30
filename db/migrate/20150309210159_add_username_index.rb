class AddUsernameIndex < ActiveRecord::Migration
  disable_ddl_transaction!

  def up
    execute 'CREATE INDEX CONCURRENTLY index_users_on_username_lower ON users(lower(username))'
  end

  def down
    execute 'DROP INDEX CONCURRENTLY index_users_on_username_lower'
  end
end
