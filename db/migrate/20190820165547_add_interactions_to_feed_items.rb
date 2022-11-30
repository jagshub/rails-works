class AddInteractionsToFeedItems < ActiveRecord::Migration[5.1]
  def change
    add_column :stream_feed_items, :interactions, :jsonb
  end
end
