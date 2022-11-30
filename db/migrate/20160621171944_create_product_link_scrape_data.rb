class CreateProductLinkScrapeData < ActiveRecord::Migration
  def change
    create_table :product_link_scrape_data do |t|
      t.references :product_link, index: true, foreign_key: true, null: false
      t.jsonb :data, default: {}, null: false

      t.timestamps null: false
    end
  end
end
