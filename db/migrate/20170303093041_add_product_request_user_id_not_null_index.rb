class AddProductRequestUserIdNotNullIndex < ActiveRecord::Migration
  def change
    change_column_null :product_requests, :user_id, false
  end
end
