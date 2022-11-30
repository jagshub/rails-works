class ChangeSipDevicesPrimaryKeyToToken < ActiveRecord::Migration[5.0]
  def up
    enable_extension :"uuid-ossp"
    remove_column :sip_devices, :id, :primary_key
    remove_column :sip_devices, :token, :string
    add_column :sip_devices, :token, :uuid, default: 'uuid_generate_v4()', null: false
    rename_column :sip_devices, :token, :id
    execute "ALTER TABLE sip_devices ADD PRIMARY KEY (id);"
    add_index :sip_devices, :id
  end

  def down
    remove_column :sip_devices, :id
    add_column :sip_devices, :id, :primary_key
    add_column :sip_devices, :token, :string, default: '', null: false
  end
end
