class AddUserUsernameUniqueIdx < ActiveRecord::Migration
  def change
    execute 'commit;'
    execute 'DROP INDEX CONCURRENTLY index_users_on_username'
    execute 'CREATE UNIQUE INDEX CONCURRENTLY index_users_on_username ON users(lower(username))'
    execute 'begin;'
  end
end
