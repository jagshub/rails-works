class RemoveProductTopicAssociationsDuplicatedIndex < ActiveRecord::Migration[6.1]
  def change
    remove_index(
      :product_topic_associations,
      name: "index_product_topic_associations_on_product_id",
      column: :product_id
    )
  end
end
