class RemoveProductIdIndexesFromProductRequests < ActiveRecord::Migration[6.1]
  def change
    change_column_null :recommended_products, :product_id, true
    remove_index :recommended_products, :product_id
    remove_index :recommended_products, [:product_request_id, :product_id]
  end
end
