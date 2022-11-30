class AddThumbnailMediaIdToProduct < ActiveRecord::Migration
  def change
    add_column :products, :thumbnail_media_id, :integer
  end
end
