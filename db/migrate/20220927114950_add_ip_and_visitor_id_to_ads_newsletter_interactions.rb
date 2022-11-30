class AddIpAndVisitorIdToAdsNewsletterInteractions < ActiveRecord::Migration[6.1]
  def change
    add_column :ads_newsletter_interactions, :ip_address, :string
    add_column :ads_newsletter_interactions, :visitor_id, :string
  end
end
