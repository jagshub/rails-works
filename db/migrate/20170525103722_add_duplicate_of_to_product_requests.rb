class AddDuplicateOfToProductRequests < ActiveRecord::Migration
  def change
    add_reference :product_requests, :duplicate_of, index: true
  end
end
