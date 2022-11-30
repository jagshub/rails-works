class RecreateUserIndices < ActiveRecord::Migration
  disable_ddl_transaction!

  def up
    execute 'CREATE UNIQUE INDEX CONCURRENTLY ON users(username) WHERE trashed_at IS NULL'
    execute 'CREATE UNIQUE INDEX CONCURRENTLY ON users(twitter_uid) WHERE trashed_at IS NULL'
    execute 'CREATE UNIQUE INDEX CONCURRENTLY ON users(facebook_uid) WHERE trashed_at IS NULL'

    execute 'DROP INDEX CONCURRENTLY index_users_on_username'
    execute 'DROP INDEX CONCURRENTLY index_users_on_twitter_uid'
    execute 'DROP INDEX CONCURRENTLY index_users_on_facebook_uid'
  end

  def down
    execute 'CREATE UNIQUE INDEX CONCURRENTLY index_users_on_username ON users(username)'
    execute 'CREATE UNIQUE INDEX CONCURRENTLY index_users_on_twitter_uid ON users(twitter_uid)'
    execute 'CREATE UNIQUE INDEX CONCURRENTLY index_users_on_facebook_uid ON users(facebook_uid)'

    execute 'DROP INDEX CONCURRENTLY users_facebook_uid_idx'
    execute 'DROP INDEX CONCURRENTLY users_twitter_uid_idx'
    execute 'DROP INDEX CONCURRENTLY users_username_idx'
  end
end
