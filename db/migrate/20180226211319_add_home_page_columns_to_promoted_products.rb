class AddHomePageColumnsToPromotedProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :promoted_products, :open_as_post_page, :boolean, default: false
  end
end
