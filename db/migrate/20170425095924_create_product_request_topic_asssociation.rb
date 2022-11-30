class CreateProductRequestTopicAsssociation < ActiveRecord::Migration
  def change
    create_table :product_request_topic_associations do |t|
      t.integer :product_request_id, null: false
      t.integer :topic_id, null: false
      t.timestamps null: false
    end

    add_foreign_key :product_request_topic_associations, :product_requests
    add_foreign_key :product_request_topic_associations, :topics

    add_index :product_request_topic_associations, [:product_request_id, :topic_id], unique: true, name: 'product_request_topic_associations_product_request_topic'
  end
end
