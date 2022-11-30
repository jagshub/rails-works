class RemoveMediaRelatedColumnsFromProducts < ActiveRecord::Migration
  def change
    remove_column :product_media, :product_id
    remove_column :products, :header_media_id
    remove_column :products, :thumbnail_media_id
    remove_column :products, :social_image_media_id
  end
end
