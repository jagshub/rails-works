class AddWeightToAdsNewsletters < ActiveRecord::Migration[6.1]
  def change
    add_column :ads_newsletters, :weight, :integer, default: 0, null: false
  end
end
