class AddUserNotSubscribedToAmaEventToBanners < ActiveRecord::Migration
  def change
    change_table :banners do |t|
      t.boolean :user_not_subscribed_to_ama_event, default: false, null: false
    end
  end
end
