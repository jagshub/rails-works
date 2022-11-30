class FixFrontpagePostsIndex < ActiveRecord::Migration
  disable_ddl_transaction!

  def change
    execute 'DROP INDEX CONCURRENTLY posts_created_at_idx'
    execute 'DROP INDEX CONCURRENTLY posts_published_at_idx'

    add_index :posts, :created_at, where: 'trashed_at IS NULL', algorithm: :concurrently
    add_index :posts, :featured_at, where: 'trashed_at IS NULL', algorithm: :concurrently
  end
end
