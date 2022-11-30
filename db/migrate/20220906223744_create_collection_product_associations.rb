class CreateCollectionProductAssociations < ActiveRecord::Migration[6.1]
  def change
    create_table :collection_product_associations do |t|
      t.references :collection, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true

      t.timestamps
    end

    add_index :collection_product_associations, [:collection_id, :product_id], unique: true, name: 'index_collection_product_assoc_on_collection_id_and_product_id'
  end
end
