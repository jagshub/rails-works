class RenameProductRequestRecommendationsCountToRecommendedProductsCount < ActiveRecord::Migration
  def change
    rename_column :product_requests, :recommendations_count, :recommended_products_count
  end
end
