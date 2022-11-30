class CreateFounderClubRedemptionCodesAndClaims < ActiveRecord::Migration[5.0]
  def change
    rename_column :founder_club_deals, :partner_website, :redemption_url

    create_table :founder_club_redemption_codes do |t|
      t.belongs_to :deal, index: true, null: false
      t.string :code, null: true
      t.integer :kind, default: 0, null: false
      t.integer :limit, default: 1, null: false
      t.integer :claims_count, default: 0, null: false
      t.timestamps
    end

    add_index :founder_club_redemption_codes, %i(deal_id code), unique: true

    create_table :founder_club_claims do |t|
      t.belongs_to :deal, index: true, null: false
      t.belongs_to :user, foreign_key: true, index: true, null: false
      t.belongs_to :redemption_code, index: true, null: false
      t.timestamps
    end

    add_index :founder_club_claims, %i(deal_id user_id), unique: true

    add_foreign_key :founder_club_redemption_codes, :founder_club_deals, column: :deal_id
    add_foreign_key :founder_club_claims, :founder_club_deals, column: :deal_id
    add_foreign_key :founder_club_claims, :founder_club_redemption_codes, column: :redemption_code_id
  end
end
