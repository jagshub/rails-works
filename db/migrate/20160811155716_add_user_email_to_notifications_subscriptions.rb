class AddUserEmailToNotificationsSubscriptions < ActiveRecord::Migration
  def change
    add_column :notifications_subscribers, :real_email, :string
    add_index :notifications_subscribers, :real_email, unique: true
  end
end
