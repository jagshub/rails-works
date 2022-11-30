class AddRecommendedProductProductIdUniqueIndex < ActiveRecord::Migration
  def change
    add_index :recommended_products, [:product_request_id, :product_id], unique: true
  end
end
