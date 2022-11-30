class RenameProductsTableToLegacyProducts < ActiveRecord::Migration[5.2]
  def change
    safety_assured { rename_table :products, :legacy_products }
  end
end
