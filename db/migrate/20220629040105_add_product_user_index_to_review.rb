class AddProductUserIndexToReview < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index :reviews, %i(product_id user_id), algorithm: :concurrently
    remove_index :reviews, :product_id
  end
end
