class AddMissingIndices < ActiveRecord::Migration
  disable_ddl_transaction!

  def change
    add_index :posts, :url_host, algorithm: :concurrently
    add_index :comment_votes, :user_id, algorithm: :concurrently
    add_index :product_makers, :user_id, algorithm: :concurrently
    add_index :product_makers, :post_id, algorithm: :concurrently
  end
end
