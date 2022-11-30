class AddSocialImageMediaToProduct < ActiveRecord::Migration
  def change
    add_column :products, :social_image_media_id, :integer, null: true
  end
end
