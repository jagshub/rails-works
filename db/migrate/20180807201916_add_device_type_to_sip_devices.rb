class AddDeviceTypeToSipDevices < ActiveRecord::Migration[5.0]
  def change
    add_column :sip_devices, :device_type, :integer, default: 0, null: false
  end
end
