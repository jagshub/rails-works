class AddHeaderImageUrlToLists < ActiveRecord::Migration
  def change
    add_column :lists, :header_image_url, :string
  end
end
