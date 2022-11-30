class AddHiddenAtToProductRequests < ActiveRecord::Migration
  def change
    add_column :product_requests, :hidden_at, :timestamp
    add_index :product_requests, :hidden_at
  end
end
