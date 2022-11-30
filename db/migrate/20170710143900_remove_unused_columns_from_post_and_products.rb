class RemoveUnusedColumnsFromPostAndProducts < ActiveRecord::Migration
  def change
    remove_column :posts, :clicks
    remove_column :posts, :feature_notifications_sent_at
    remove_column :posts, :hide
    remove_column :posts, :show_video_in_post_list
    remove_column :posts, :background_color
    remove_column :posts, :suppress_notifications

    remove_column :products, :verified
    remove_column :products, :new_version
    remove_column :products, :screenshot_url
  end
end
