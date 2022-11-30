class AddPostIdToLegacyLinks < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_column :legacy_product_links, :post_id, :integer, null: true
    add_index :legacy_product_links, [:primary_link, :post_id], algorithm: :concurrently
    add_foreign_key :legacy_product_links, :posts, validate: false

    change_column_null :legacy_product_links, :product_id, true
    change_column_null :posts, :product_id, true
  end
end
