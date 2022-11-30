class UpdateProductsTaglineToNonNull < ActiveRecord::Migration[6.1]
  def change
    change_column_null :products, :tagline, false
  end
end
