class AddCampaignNameToPromotedEmailCampaign < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def change
    add_column :promoted_email_campaigns, :campaign_name, :string
    add_index :promoted_email_campaigns, :campaign_name, where: 'campaign_name IS NOT NULL', algorithm: :concurrently
  end
end
