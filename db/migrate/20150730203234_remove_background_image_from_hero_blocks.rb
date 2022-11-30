class RemoveBackgroundImageFromHeroBlocks < ActiveRecord::Migration
  def change
    remove_column :hero_blocks, :background_image
    change_column_null :hero_blocks, :background_image_uuid, false
  end
end
