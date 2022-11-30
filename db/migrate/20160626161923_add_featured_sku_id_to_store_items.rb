class AddFeaturedSkuIdToStoreItems < ActiveRecord::Migration
  def change
    add_column :store_items, :featured_sku_id, :string
  end
end
