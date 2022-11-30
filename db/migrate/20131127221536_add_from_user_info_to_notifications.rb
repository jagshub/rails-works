class AddFromUserInfoToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :from_user_name, :string
    add_column :notifications, :from_user_image, :string
  end
end
