class RemoveProductIdFromRecommendedProducts < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      remove_column :recommended_products, :product_id, :integer
    end
  end
end
