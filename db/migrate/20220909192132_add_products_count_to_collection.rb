class AddProductsCountToCollection < ActiveRecord::Migration[6.1]
  def change
    add_column :collections, :products_count, :integer, null: false, default: 0
  end
end
