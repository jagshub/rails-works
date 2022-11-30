class RenameAdsPlacementsToAdsChannels < ActiveRecord::Migration[5.1]
  def change
    safety_assured {
      rename_table :ads_placements, :ads_channels
      rename_column :ads_interactions, :placement_id, :channel_id
      rename_column :ads_budgets, :placements_count, :channels_count
      rename_column :ads_budgets,
                    :active_placements_count,
                    :active_channels_count
    }
  end
end
