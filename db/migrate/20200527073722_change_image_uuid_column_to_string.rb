class ChangeImageUuidColumnToString < ActiveRecord::Migration[5.1]
  def change
    safety_assured do
      change_column :collections, :image_uuid, :string
      change_column :embeds, :favicon_image_uuid, :string
      change_column :promoted_products, :thumbnail_uuid, :string
      change_column :topics, :image_uuid, :string
      change_column :users, :header_uuid, :string
      change_column :promoted_email_ab_test_variants, :thumbnail_uuid, :string
      change_column :promoted_email_campaigns, :thumbnail_uuid, :string, null: false
      change_column :radio_sponsors, :image_uuid, :string, null: false
    end
  end
end
