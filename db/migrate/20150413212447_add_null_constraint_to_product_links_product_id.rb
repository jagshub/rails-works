class AddNullConstraintToProductLinksProductId < ActiveRecord::Migration
  def change
    change_column_null :product_links, :product_id, false
  end
end
