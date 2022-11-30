class AddPriorityToBanners < ActiveRecord::Migration
  def change
    change_table :banners do |t|
      t.integer :priority, default: 0, null: false
    end
  end
end
