class CreateProductScrapeResults < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    create_table :product_scrape_results do |t|
      t.belongs_to :product, null: false, index: false, foreign_key: true
      t.string :url
      t.string :source, null: false
      t.jsonb :data, null: false

      t.timestamps
    end

    add_index :product_scrape_results,
              %i(product_id source),
              unique: true,
              algorithm: :concurrently
  end
end
