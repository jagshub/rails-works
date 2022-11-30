class DropSipDeviceViews < ActiveRecord::Migration[5.1]
  def change
    drop_table :sip_device_views
  end
end
