class CreatePromotedEmailCampaignConfigs < ActiveRecord::Migration[5.1]
  def change
    safety_assured do
      create_table :promoted_email_campaign_configs do |t|
        t.string :campaign_name, null: false, unique: true
        t.integer :signups_cap, null: false, default: -1
        t.integer :signups_count, null: false, default: 0

        t.timestamps
      end

      add_column :promoted_email_campaigns, :signups_count, :integer, null: false, default: 0
    end
  end
end
