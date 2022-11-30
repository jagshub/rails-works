class AddApplicationEnumToAdsChannels < ActiveRecord::Migration[6.1]
  def change
    add_column :ads_channels, :application, :string, null: false, default: 'all_apps'
  end
end
