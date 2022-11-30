class RemoveNotUsedIndexFromMobileDevices < ActiveRecord::Migration[6.1]
  def change
    remove_index :mobile_devices, :user_id
  end
end
