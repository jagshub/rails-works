class AddDeviceMetadataToUpcomingPageSubscribers < ActiveRecord::Migration[5.0]
  def change
    change_table :upcoming_page_subscribers do |t|
      t.integer :device_type, null: true
      t.string :os, null: true

      t.string :user_agent, null: true
      t.string :ip_address, null: true
    end
  end
end
