class CreatePromotedEmailCampaigns < ActiveRecord::Migration[5.1]
  def change
    create_table :promoted_email_campaigns do |t|
      t.string :title, null: false
      t.string :tagline, null: false
      t.uuid :thumbnail_uuid, null: false
      t.integer :promoted_type, null: false, default: 0
      t.datetime :start_date, null: false
      t.datetime :end_date, null: false
      t.boolean :webhook_enabled, null: false, default: false
      t.string :webhook_url
      t.string :webhook_auth_header
      t.string :webhook_payload

      t.timestamps
    end
  end
end
