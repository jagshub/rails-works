class AddNonNullConstraintOnAdsChannelsUrl < ActiveRecord::Migration[5.1]
  def change
    change_column_null :ads_channels, :url, false
    change_column_null :ads_channels, :url_params, false
  end
end
