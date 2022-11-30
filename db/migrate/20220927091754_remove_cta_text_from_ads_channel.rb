class RemoveCtaTextFromAdsChannel < ActiveRecord::Migration[6.1]
  def change
    safety_assured { remove_column :ads_channels, :cta_text, :string }
  end
end
