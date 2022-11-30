class AddSkuIdToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :sku_id, :string
  end
end
