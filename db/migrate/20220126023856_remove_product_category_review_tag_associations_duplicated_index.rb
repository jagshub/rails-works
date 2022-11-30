class RemoveProductCategoryReviewTagAssociationsDuplicatedIndex < ActiveRecord::Migration[6.1]
  def change
    remove_index :product_category_associations, name: 'index_product_category_associations_on_product_id', column: :product_id
    remove_index :review_tag_associations, name: 'index_review_tag_associations_on_review_id', column: :review_id
  end
end
