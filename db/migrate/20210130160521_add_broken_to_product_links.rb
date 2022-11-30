class AddBrokenToProductLinks < ActiveRecord::Migration[5.1]
  def up
    add_column :product_links, :broken, :boolean
    change_column_default :product_links, :broken, false
  end

  def down
    remove_column :product_links, :broken
  end
end
