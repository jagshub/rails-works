class AddAngellistUrlToProducts < ActiveRecord::Migration
  def change
    add_column :products, :angellist_url, :string
  end
end
