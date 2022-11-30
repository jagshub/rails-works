class CreateProductCategoryAssociations < ActiveRecord::Migration[5.2]
  def change
    create_table :product_category_associations do |t|
      t.references :product, null: false, index: true
      t.references :category, null: false, index: true, to: { table: :product_categories }
      t.string :source, null: false

      t.timestamps
    end

    add_index(
      :product_category_associations,
      [:product_id, :category_id],
      unique: true,
      name: :index_product_category_associations_on_product_and_category,
    )
  end
end
