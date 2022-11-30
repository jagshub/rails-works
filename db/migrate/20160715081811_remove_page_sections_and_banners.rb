class RemovePageSectionsAndBanners < ActiveRecord::Migration
  def change
    drop_table :page_contents
    drop_table :page_sections
    drop_table :banners
  end
end
