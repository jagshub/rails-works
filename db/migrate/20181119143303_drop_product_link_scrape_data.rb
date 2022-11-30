class DropProductLinkScrapeData < ActiveRecord::Migration[5.0]
  def change
    drop_table :product_link_scrape_data
  end
end
