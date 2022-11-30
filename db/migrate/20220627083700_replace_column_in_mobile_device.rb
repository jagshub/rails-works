class ReplaceColumnInMobileDevice < ActiveRecord::Migration[6.1]
  def change
    add_column :mobile_devices, :send_product_mention_push, :boolean, null: false, default: true
    safety_assured do
      remove_column :mobile_devices, :send_product_maker_push, :boolean
    end
  end
end
