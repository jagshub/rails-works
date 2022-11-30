class AddFeaturedAtToProductRequests < ActiveRecord::Migration
  def change
    add_column :product_requests, :featured_at, :datetime
    add_index :product_requests, :featured_at
  end
end
