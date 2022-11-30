class CreateProductCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :product_categories do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :description
      t.references :parent, index: true, null: true, to: { table: :product_categories }

      t.integer :products_count, null: false, default: 0
      t.integer :children_categories_count, null: false, default: 0

      t.timestamps
    end
  end
end
