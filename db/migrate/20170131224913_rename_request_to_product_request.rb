class RenameRequestToProductRequest < ActiveRecord::Migration
  def change
    rename_table :requests, :product_requests
    rename_column :recommended_products, :request_id, :product_request_id
  end
end
