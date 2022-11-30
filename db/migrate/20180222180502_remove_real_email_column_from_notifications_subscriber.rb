class RemoveRealEmailColumnFromNotificationsSubscriber < ActiveRecord::Migration[5.0]
  def change
    remove_column :notifications_subscribers, :real_email, :string
  end
end
