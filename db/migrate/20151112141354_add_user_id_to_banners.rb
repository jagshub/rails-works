class AddUserIdToBanners < ActiveRecord::Migration
  def change
    change_table :banners do |t|
      t.integer :user_id
    end
  end
end
