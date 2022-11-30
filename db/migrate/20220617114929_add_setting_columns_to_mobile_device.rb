class AddSettingColumnsToMobileDevice < ActiveRecord::Migration[6.1]
  def change
    add_column :mobile_devices, :send_mention_push, :boolean, null: false, default: true
    add_column :mobile_devices, :send_new_follower_push, :boolean, null: false, default: true
    add_column :mobile_devices, :send_friend_post_push, :boolean, null: false, default: true
    add_column :mobile_devices, :send_comment_upvotes_push, :boolean, null: false, default: true
    add_column :mobile_devices, :send_comment_on_post_push, :boolean, null: false, default: true
    add_column :mobile_devices, :send_post_upvotes_push, :boolean, null: false, default: true
    add_column :mobile_devices, :send_reply_on_comments_push, :boolean, null: false, default: true
    add_column :mobile_devices, :send_trending_posts_push, :boolean, null: false, default: true
    add_column :mobile_devices, :send_community_updates_push, :boolean, null: false, default: true
    add_column :mobile_devices, :send_product_request_push, :boolean, null: false, default: true
  end
end
