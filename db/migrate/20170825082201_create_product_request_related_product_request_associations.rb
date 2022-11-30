class CreateProductRequestRelatedProductRequestAssociations < ActiveRecord::Migration
  def change
    create_table :product_request_related_product_request_associations do |t|
      t.references :product_request, index: { name: 'index_related_product_requests_on_product_request' }, foreign_key: true, null: false
      t.references :related_product_request, index: { name: 'index_related_product_requests_on_related_product_request' }, references: :product_requests, null: false
      t.references :user, index: false

      t.timestamps null: false
    end

    add_column :product_requests, :related_product_requests_count, :integer, null: false, default: 0
    add_foreign_key :product_request_related_product_request_associations, :product_requests, column: :related_product_request_id
    add_index :product_request_related_product_request_associations, [:product_request_id, :related_product_request_id], unique: true, name: 'index_related_product_requests_on_product_requests'
  end
end
