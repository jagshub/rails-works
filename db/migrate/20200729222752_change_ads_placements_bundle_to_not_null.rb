class ChangeAdsPlacementsBundleToNotNull < ActiveRecord::Migration[5.1]
  def up
    safety_assured {
      change_column :ads_placements, :bundle, :string, null: true
    }
  end

  def down
  end
end
