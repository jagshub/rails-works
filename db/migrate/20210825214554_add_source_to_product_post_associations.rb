class AddSourceToProductPostAssociations < ActiveRecord::Migration[5.2]
  def change
    add_column :product_post_associations, :source, :string, null: false
  end
end
