class FixProductLinkIndexes < ActiveRecord::Migration[5.0]
  disable_ddl_transaction!

  def up
    add_index :product_links, [:product_id, :primary_link], algorithm: :concurrently
    execute 'DROP INDEX CONCURRENTLY index_product_links_on_product_id'
  end

  def down
    add_index :product_links, [:product_id], algorithm: :concurrently
    execute 'DROP INDEX CONCURRENTLY index_product_links_on_product_id_and_primary_link'
  end
end
