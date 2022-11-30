class AddIndexOnPostsFeaturedAtScheduledAt < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index :posts, [:featured_at, :scheduled_at], name: "index_posts_on_featured_at_scheduled_at", algorithm: :concurrently
  end
end
