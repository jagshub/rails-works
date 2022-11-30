class AddTrashedAtToPosts < ActiveRecord::Migration
  disable_ddl_transaction!

  def change
    add_column :posts, :trashed_at, :datetime

    execute('CREATE INDEX CONCURRENTLY ON posts(created_at) WHERE NOT hide AND trashed_at IS NULL;')
    execute('CREATE INDEX CONCURRENTLY ON posts(published_at) WHERE NOT hide AND trashed_at IS NULL;')
    execute('CREATE INDEX CONCURRENTLY ON posts(user_id) WHERE trashed_at IS NULL;')
  end
end
