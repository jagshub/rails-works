class DropSipDevices < ActiveRecord::Migration[5.1]
  def change
    drop_table :sip_devices
  end
end
