class CreateRelatedProductAssociations < ActiveRecord::Migration[6.1]
  def change
    create_table :related_product_associations do |t|
      t.references :product, null: false, index: false
      t.references :related_product, null: false, index: false

      t.string :relationship, null: false
      t.string :source, null: false

      t.timestamps null: false
    end

    add_index :related_product_associations, [:product_id, :related_product_id], unique: true, name: 'index_related_products_unique'
  end
end
