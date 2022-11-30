class RenameProductLinksTableToLegacyProductLinks < ActiveRecord::Migration[5.2]
  def change
    safety_assured { rename_table :product_links, :legacy_product_links }
  end
end
