class AddSocialBannerToMakersFestivalEditions < ActiveRecord::Migration[5.1]
  def change
    add_column :makers_festival_editions, :social_banner_uuid, :string, null: true
  end
end
