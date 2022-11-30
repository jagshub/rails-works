class AddSocialImageUuidToStoriesAndNewsletter < ActiveRecord::Migration[5.2]
  def change
    add_column :anthologies_stories, :social_image_uuid, :string, null: true
    add_column :newsletters, :social_image_uuid, :string, null: true
  end
end
