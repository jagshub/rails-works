class AddLabelToBanners < ActiveRecord::Migration
  def change
    change_table :banners do |t|
      t.string :label, null: true
    end
  end
end
