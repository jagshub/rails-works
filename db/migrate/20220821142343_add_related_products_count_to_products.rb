class AddRelatedProductsCountToProducts < ActiveRecord::Migration[6.1]
  def change
    add_column :products, :related_products_count, :integer, null: false, default: 0
  end
end
