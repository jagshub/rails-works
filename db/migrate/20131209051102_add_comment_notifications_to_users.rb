class AddCommentNotificationsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :comment_notifications, :boolean
  end
end
