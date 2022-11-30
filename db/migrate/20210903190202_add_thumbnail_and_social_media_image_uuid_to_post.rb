class AddThumbnailAndSocialMediaImageUuidToPost < ActiveRecord::Migration[5.2]
  def change
    add_column :posts, :thumbnail_image_uuid, :string
    add_column :posts, :social_media_image_uuid, :string
  end
end
