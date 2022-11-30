class AddLinkTrackersUserIdIndex < ActiveRecord::Migration
  def change
    # Avoid wrapping transaction
    execute 'commit;'

    add_index :link_trackers, :user_id, algorithm: :concurrently

    # Start a new transaction so Rails doesn't get confused
    execute 'begin;'
  end
end
