class AddMarketingCampaignToPaymentSubscriptions < ActiveRecord::Migration[5.1]
  def change
    add_column :payment_subscriptions, :marketing_campaign_name, :string
  end
end
