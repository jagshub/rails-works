class AddMailToSubscribers < ActiveRecord::Migration
  def change
    add_column :notifications_subscribers, :email, :string
  end
end
