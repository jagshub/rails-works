class AddRecommendedProductProductIdNotNullIndex < ActiveRecord::Migration
  def change
    change_column_null :recommended_products, :product_id, false
  end
end
