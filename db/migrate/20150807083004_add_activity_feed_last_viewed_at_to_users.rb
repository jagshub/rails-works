class AddActivityFeedLastViewedAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :activity_feed_last_viewed_at, :datetime
  end
end
