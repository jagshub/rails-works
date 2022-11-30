class RemoveActivityFeedLastViewedAtFromUser < ActiveRecord::Migration
  def change
    remove_column :users, :activity_feed_last_viewed_at, :datetime
  end
end
