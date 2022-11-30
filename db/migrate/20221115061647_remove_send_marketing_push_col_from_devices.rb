class RemoveSendMarketingPushColFromDevices < ActiveRecord::Migration[6.1]
  def change
    safety_assured { remove_column :mobile_devices, :send_marketing_push, :boolean }
  end
end
