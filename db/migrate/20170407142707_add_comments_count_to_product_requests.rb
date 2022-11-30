class AddCommentsCountToProductRequests < ActiveRecord::Migration
  def change
    add_column :product_requests, :comments_count, :integer, null: false, default: 0
    add_index :product_requests, :comments_count
  end
end
