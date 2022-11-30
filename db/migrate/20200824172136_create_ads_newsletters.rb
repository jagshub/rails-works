class CreateAdsNewsletters < ActiveRecord::Migration[5.1]
  def change
    create_table :ads_newsletters do |t|
      t.references :budget,
                   foreign_key: { to_table: :ads_budgets },
                   null: false,
                   index: true

      t.references :newsletter, null: false, index: true

      t.string :name, null: false
      t.string :tagline, null: false
      t.string :thumbnail_uuid, null: false
      t.string :url, null: false
      t.string :deal_text
      t.json :url_params, null: false, default: {}

      t.integer :opens_count, null: false, default: 0
      t.integer :clicks_count, null: false, default: 0
      t.integer :sends_count, null: false, default: 0

      t.timestamps
    end
  end
end
