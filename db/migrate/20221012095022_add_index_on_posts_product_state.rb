class AddIndexOnPostsProductState < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index :posts, :product_state, algorithm: :concurrently
  end
end
