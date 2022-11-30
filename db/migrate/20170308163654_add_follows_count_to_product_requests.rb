class AddFollowsCountToProductRequests < ActiveRecord::Migration
  def change
    add_column :product_requests, :followers_count, :integer, null: false, default: 0
    add_index :product_requests, :followers_count
  end
end
