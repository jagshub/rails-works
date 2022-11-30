class RemoveCollectionProductAssocDuplicatedIndex < ActiveRecord::Migration[6.1]
  def change
    remove_index(
      :collection_product_associations,
      name: "index_collection_product_associations_on_collection_id",
      column: :collection_id
    )
  end
end
