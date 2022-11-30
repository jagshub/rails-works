class RemoveYoursFeedPostIds < ActiveRecord::Migration[5.0]
  def change
    execute 'DROP MATERIALIZED VIEW yours_feed_post_ids'
  end
end
