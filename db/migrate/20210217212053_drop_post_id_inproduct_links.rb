class DropPostIdInproductLinks < ActiveRecord::Migration[5.1]
  def change
    remove_index :product_links, name: :index_product_links_on_post_id
    remove_index :product_links, name: :product_links_post_id_idx

    safety_assured { remove_column :product_links, :post_id }
  end
end
