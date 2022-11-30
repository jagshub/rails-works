class AddBackgroundImageUuidToHeroBlocks < ActiveRecord::Migration
  def change
    change_column_null :hero_blocks, :background_image, true

    add_column :hero_blocks, :background_image_uuid, :uuid
  end
end
