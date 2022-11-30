class RemoveUnusedRecommendedProductAttributes < ActiveRecord::Migration
  def change
    remove_column :recommended_products, :external_url, :text
    remove_column :recommended_products, :external_image_url, :text
    rename_column :recommended_products, :external_title, :name
  end
end
