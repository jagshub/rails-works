class AddIndexToUpcomingPageTrashedAt < ActiveRecord::Migration[5.0]
  disable_ddl_transaction!

  def change
    add_index :upcoming_pages, :trashed_at, algorithm: :concurrently
  end
end
