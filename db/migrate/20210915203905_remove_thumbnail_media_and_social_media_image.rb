class RemoveThumbnailMediaAndSocialMediaImage < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      remove_column :posts, :thumbnail_media_id
      remove_column :posts, :social_image_media_id
    end
  end
end
