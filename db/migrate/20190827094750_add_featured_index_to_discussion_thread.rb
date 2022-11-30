class AddFeaturedIndexToDiscussionThread < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def change
    add_index :discussion_threads, :featured_at, where: 'featured_at IS NOT NULL AND hidden_at IS NULL', algorithm: :concurrently
    add_index :discussion_threads, :created_at, where: 'hidden_at IS NULL', algorithm: :concurrently
  end
end
