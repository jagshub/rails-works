class CreateSimilarCollectionAssociations < ActiveRecord::Migration
  def change
    create_table :similar_collection_associations do |t|
      t.references :collection, null: false
      t.references :similar_collection, null: false
      t.timestamps null: false
    end

    add_index :similar_collection_associations, [:collection_id, :similar_collection_id], unique: true, name: 'index_similar_coll_associations_on_coll_id_and_similar_coll_id'
  end
end
