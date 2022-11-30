class AddNullConstraintToPostProductId < ActiveRecord::Migration
  def change
    change_column_null :posts, :product_id, false
  end
end
