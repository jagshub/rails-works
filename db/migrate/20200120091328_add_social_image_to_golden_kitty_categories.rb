class AddSocialImageToGoldenKittyCategories < ActiveRecord::Migration[5.1]
  def change
    add_column :golden_kitty_categories, :social_image_uuid, :string, null: true
  end
end
