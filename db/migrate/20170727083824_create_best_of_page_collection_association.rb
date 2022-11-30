class CreateBestOfPageCollectionAssociation < ActiveRecord::Migration
  def change
    create_table :best_of_page_collection_associations do |t|
      t.references :collection, null: false
      t.references :best_of_page, null: false
      t.timestamps null: false
    end

    add_index :best_of_page_collection_associations, %i(collection_id best_of_page_id), unique: true, name: 'index_best_post_assocs_on_best_of_page_id_and_collection_id'
  end
end
