class AddLinkUniqueVisitsToPromotedProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :promoted_products, :link_unique_visits, :integer, :default => 0, :null => false
  end
end
