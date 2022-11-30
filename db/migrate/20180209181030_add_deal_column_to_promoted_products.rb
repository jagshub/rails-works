class AddDealColumnToPromotedProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :promoted_products, :deal, :string
  end
end
