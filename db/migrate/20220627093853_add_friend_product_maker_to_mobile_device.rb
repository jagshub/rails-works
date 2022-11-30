class AddFriendProductMakerToMobileDevice < ActiveRecord::Migration[6.1]
  def change
    add_column :mobile_devices, :send_friend_product_maker_push, :boolean, null: false, default: true
  end
end
