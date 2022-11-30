class AddIndexToPublishedAtOnPosts < ActiveRecord::Migration
  disable_ddl_transaction!

  def up
    change_column_null :posts, :published_at, false
    execute 'CREATE INDEX CONCURRENTLY index_posts_on_published_at ON posts(published_at) WHERE NOT hide;'
  end

  def down
    remove_index :posts, :published_at
  end
end
