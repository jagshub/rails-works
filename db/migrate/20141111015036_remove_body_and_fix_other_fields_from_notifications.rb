class RemoveBodyAndFixOtherFieldsFromNotifications < ActiveRecord::Migration
  def change
    remove_column :notifications, :body
    remove_column :notifications, :from_user_image
    remove_column :notifications, :from_user_name
    change_column_null :notifications, :user_id, false
    change_column_null :notifications, :from_user_id, false
    change_column_null :notifications, :seen, false
  end
end
