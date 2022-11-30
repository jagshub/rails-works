class AddActiveFlagToAdsNewsletters < ActiveRecord::Migration[6.1]
  def change
    add_column :ads_newsletters, :active, :boolean, default: true
  end
end
