class AddStorePostIndexToLegacyProductLink < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index :legacy_product_links, %i(store post_id), where: 'post_id IS NOT NULL', algorithm: :concurrently
  end
end
