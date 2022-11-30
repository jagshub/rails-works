class AddIndexOnPostsScheduledAt < ActiveRecord::Migration[5.0]
  disable_ddl_transaction!

  def change
    add_index :posts, :scheduled_at, algorithm: :concurrently
  end
end
