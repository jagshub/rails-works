class AddGrandfatheredVerificationToSubscribers < ActiveRecord::Migration[5.1]
  def change
    add_column :notifications_subscribers, :grandfathered_verification, :boolean
  end
end
