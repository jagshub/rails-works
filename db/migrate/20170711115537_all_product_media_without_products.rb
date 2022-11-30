class AllProductMediaWithoutProducts < ActiveRecord::Migration
  def change
    change_column_null :product_media, :product_id, true
  end
end
