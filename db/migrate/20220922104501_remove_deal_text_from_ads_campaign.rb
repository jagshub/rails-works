class RemoveDealTextFromAdsCampaign < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      remove_column :ads_campaigns, :deal_text, :string
      end
  end
end