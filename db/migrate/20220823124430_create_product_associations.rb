class CreateProductAssociations < ActiveRecord::Migration[6.1]
  def change
    create_table :product_associations do |t|
      t.references :product, null: false, index: false
      t.references :associated_product, null: false, index: false

      t.string :relationship, null: false
      t.string :source, null: false

      t.timestamps null: false
    end

    add_index :product_associations, [:product_id, :associated_product_id], unique: true, name: 'index_product_associations_unique'
  end
end
