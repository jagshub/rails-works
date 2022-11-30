class AddSectionToBanners < ActiveRecord::Migration
  def change
    change_table :banners do |t|
      t.integer :section
    end
  end
end
