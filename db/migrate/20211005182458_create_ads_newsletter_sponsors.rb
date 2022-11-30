class CreateAdsNewsletterSponsors < ActiveRecord::Migration[5.2]
  def change
    create_table :ads_newsletter_sponsors do |t|
      t.references :budget, foreign_key: { to_table: :ads_budgets }, index: true
      t.string :image_uuid, null: false
      t.string :url, null: false
      t.json :url_params, null: false, default: {}
      t.string :description_html, null: false
      t.string :cta
      t.boolean :active, default: true, null: false
      t.integer :weight, default: 0, null: false
      t.timestamps
    end
  end
end
