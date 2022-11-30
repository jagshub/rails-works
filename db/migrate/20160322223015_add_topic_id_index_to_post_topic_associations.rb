class AddTopicIdIndexToPostTopicAssociations < ActiveRecord::Migration
  disable_ddl_transaction!

  def change
    add_index :post_topic_associations, [:topic_id, :post_id], algorithm: :concurrently
  end
end
