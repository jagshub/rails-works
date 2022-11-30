class AddUsernameAndNameGinIndexToUsers < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def up
    remove_index :users, name: 'index_users_on_username'
    remove_index :users, name: 'users_username_idx'

    safety_assured do
      execute "CREATE INDEX CONCURRENTLY users_on_username_fast ON users USING gin (username gin_trgm_ops)"
      execute "CREATE INDEX CONCURRENTLY users_on_name_fast ON users USING gin (name gin_trgm_ops)"
    end
  end

  def down
    remove_index :users, name: 'users_on_username_fast'
    remove_index :users, name: 'users_on_name_fast'

    add_index :users, :username, unique: true, where: 'trashed_at IS NULL', name: 'users_username_idx'
    add_index :users, :username
  end
end
