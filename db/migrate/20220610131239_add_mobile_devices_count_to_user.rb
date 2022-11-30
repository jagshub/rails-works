class AddMobileDevicesCountToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :mobile_devices_count, :integer, null: false, default: 0
  end
end
