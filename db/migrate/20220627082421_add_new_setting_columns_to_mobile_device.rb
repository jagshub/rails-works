class AddNewSettingColumnsToMobileDevice < ActiveRecord::Migration[6.1]
  def change
    add_column :mobile_devices, :send_missed_post_push, :boolean, null: false, default: true
    add_column :mobile_devices, :send_product_maker_push, :boolean, null: false, default: true
    add_column :mobile_devices, :send_top_post_competition_push, :boolean, null: false, default: true
  end
end
