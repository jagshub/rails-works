class CreatePromotedEmailSignups < ActiveRecord::Migration[5.1]
  def change
    create_table :promoted_email_signups do |t|
      t.string :email, null: false
      t.references :promoted_email_campaign, foreign_key: true, null: false
      t.references :user, foreign_key: true, index: false
      t.string :ip_address
      t.string :track_code

      t.timestamps
    end

    add_index :promoted_email_signups, %i(email promoted_email_campaign_id), unique: true, name: 'index_promoted_email_email_campaign_id'
    add_index :promoted_email_signups, %i(user_id promoted_email_campaign_id), unique: true, where: 'user_id is NOT NULL', name: 'index_promoted_email_user_campaign_id'
  end
end
