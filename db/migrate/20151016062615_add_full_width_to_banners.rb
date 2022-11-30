class AddFullWidthToBanners < ActiveRecord::Migration
  def change
    change_table :banners do |t|
      t.boolean :full_width, default: false, null: false
    end
  end
end
