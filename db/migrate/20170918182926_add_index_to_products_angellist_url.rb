class AddIndexToProductsAngellistUrl < ActiveRecord::Migration
  def change
    add_index :products, :angellist_url
  end
end
