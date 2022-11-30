class ChangeCampaignThumbnailUuidToString < ActiveRecord::Migration[5.1]
  def change
    safety_assured {
      change_column :ads_campaigns, :thumbnail_uuid, :string
    }
  end

  def down
    change_column :ads_campaigns, :thumbnail, 'uuid USING thumbnail_uuid::uuid'
  end
end
