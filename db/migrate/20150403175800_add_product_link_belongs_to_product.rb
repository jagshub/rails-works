class AddProductLinkBelongsToProduct < ActiveRecord::Migration
  def change
    add_reference :product_links, :product, index: true, foreign_key: true
  end
end
