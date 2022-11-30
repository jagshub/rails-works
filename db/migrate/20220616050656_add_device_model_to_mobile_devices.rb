class AddDeviceModelToMobileDevices < ActiveRecord::Migration[6.1]
  def change
    add_column :mobile_devices, :device_model, :string, null: true
  end
end
