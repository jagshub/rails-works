class RemoveNotNullFromProductRequests < ActiveRecord::Migration
  def change
    change_column_null(:product_requests, :body, true)
  end
end
