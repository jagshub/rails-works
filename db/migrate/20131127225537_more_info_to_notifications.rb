class MoreInfoToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :from_user_id, :integer
    add_column :notifications, :seen, :boolean
  end
end
