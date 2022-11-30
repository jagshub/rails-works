class MakeNewProductIdNotNull < ActiveRecord::Migration[6.1]
  def change
    change_column_null :recommended_products, :new_product_id, false
  end
end
