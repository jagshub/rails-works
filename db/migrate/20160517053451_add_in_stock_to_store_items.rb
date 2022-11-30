class AddInStockToStoreItems < ActiveRecord::Migration
  def change
    add_column :store_items, :in_stock, :boolean, default: true
  end
end
