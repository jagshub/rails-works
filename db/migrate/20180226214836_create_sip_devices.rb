class CreateSipDevices < ActiveRecord::Migration[5.0]
  def change
    create_table :sip_devices do |t|
      t.string :token, null: false
      t.string :device_uuid
      t.string :device_platform
      t.string :device_version
      t.string :device_model
      t.string :onesignal_user_id
      t.datetime :last_active_at, null: false

      t.timestamps
    end
  end
end
