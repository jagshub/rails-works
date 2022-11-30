class AddSuppressNotificationsFlagToPost < ActiveRecord::Migration
  def change
    add_column :posts, :suppress_notifications, :boolean, default: false, null: false
  end
end
