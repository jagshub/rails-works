class AddSendMarketingPushToDevice < ActiveRecord::Migration[6.1]
  def change
    add_column :mobile_devices, :send_marketing_push, :boolean, default: true, null: false
  end
end
