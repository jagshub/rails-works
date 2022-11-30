class AddNewNotificationTypesToNotificationSettings < ActiveRecord::Migration
  def change
    add_column :notifications_settings, :send_new_follower_push, :boolean, null: false, default: true
    add_column :notifications_settings, :send_new_follower_email, :boolean, null: false, default: true
    add_column :notifications_settings, :send_announcement_push, :boolean, null: false, default: true
    add_column :notifications_settings, :send_announcement_email, :boolean, null: false, default: true
    add_column :notifications_settings, :send_product_recommendation_push, :boolean, null: false, default: true
    add_column :notifications_settings, :send_product_recommendation_email, :boolean, null: false, default: true
  end
end
