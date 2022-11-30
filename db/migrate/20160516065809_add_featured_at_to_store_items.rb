class AddFeaturedAtToStoreItems < ActiveRecord::Migration
  def change
    add_column :store_items, :featured_at, :datetime, null: true
    add_index :store_items, :featured_at
  end
end
