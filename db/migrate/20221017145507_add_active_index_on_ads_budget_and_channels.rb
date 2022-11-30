class AddActiveIndexOnAdsBudgetAndChannels < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    safety_assured do
      execute 'CREATE INDEX CONCURRENTLY index_ads_channels_find_ad ON ads_channels (weight DESC, active, kind)'
    end

    remove_index :ads_channels, :weight
  end
end
