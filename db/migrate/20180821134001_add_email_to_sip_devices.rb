class AddEmailToSipDevices < ActiveRecord::Migration[5.0]
  def change
    add_reference :sip_devices, :email, foreign_key: true
  end
end
