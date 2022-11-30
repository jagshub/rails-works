class AddAnonymousToProductRequests < ActiveRecord::Migration
  def change
    add_column :product_requests, :anonymous, :boolean, default: false
  end
end
