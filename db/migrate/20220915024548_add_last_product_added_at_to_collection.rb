class AddLastProductAddedAtToCollection < ActiveRecord::Migration[6.1]
  def change
    add_column :collections, :last_product_added_at, :datetime
  end
end
