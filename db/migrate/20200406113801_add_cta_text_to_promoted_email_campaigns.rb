class AddCtaTextToPromotedEmailCampaigns < ActiveRecord::Migration[5.1]
  def change
    safety_assured do
      add_column :promoted_email_campaigns, :cta_text, :string, null: true
      add_column :promoted_email_ab_test_variants, :cta_text, :string, null: true
    end
  end
end
