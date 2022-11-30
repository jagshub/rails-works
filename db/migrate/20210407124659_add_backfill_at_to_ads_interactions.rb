class AddBackfillAtToAdsInteractions < ActiveRecord::Migration[5.1]
  def change
    add_column :ads_interactions, :backfill_at, :datetime, null: true
  end
end
