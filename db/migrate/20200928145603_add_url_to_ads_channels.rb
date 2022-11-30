class AddUrlToAdsChannels < ActiveRecord::Migration[5.1]
  def change
    add_column :ads_channels, :url, :string
    safety_assured {
      add_column :ads_channels, :url_params, :json
    }
    change_column_default :ads_channels, :url_params, from: nil, to: {}
  end
end
