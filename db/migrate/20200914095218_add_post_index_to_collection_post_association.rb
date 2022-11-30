class AddPostIndexToCollectionPostAssociation < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def change
    add_index :collection_post_associations, :post_id, algorithm: :concurrently
  end
end
