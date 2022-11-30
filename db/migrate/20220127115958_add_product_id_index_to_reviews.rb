class AddProductIdIndexToReviews < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index :reviews, :product_id, algorithm: :concurrently
  end
end
