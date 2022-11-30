class RemoveDuplicateRelatedProductRequestIndexes < ActiveRecord::Migration
  def up
    remove_index :product_request_related_product_request_associations, name: 'index_related_product_requests_on_product_request'
  end
end
