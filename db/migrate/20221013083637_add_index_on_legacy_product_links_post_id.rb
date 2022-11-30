class AddIndexOnLegacyProductLinksPostId < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index :legacy_product_links, :post_id, algorithm: :concurrently
  end
end
