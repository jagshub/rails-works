class RemoveNotNullTypeFromNotifications < ActiveRecord::Migration
  def change
    change_column_null :notifications, :type, true
    change_column_null :notifications, :kind, false
  end
end
