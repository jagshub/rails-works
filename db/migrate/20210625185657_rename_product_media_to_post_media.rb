class RenameProductMediaToPostMedia < ActiveRecord::Migration[5.2]
  def change
    safety_assured {
      rename_table :product_media, :post_media
    }
  end
end
