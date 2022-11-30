class AddCommentIdToNotifications < ActiveRecord::Migration
  def change
    add_reference :notifications, :comment, index: true
  end
end
