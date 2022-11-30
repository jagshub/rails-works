class AddNullConstraintToProductLinkBroken < ActiveRecord::Migration[5.1]
  class ProductLink < ApplicationRecord; end

  def change
    ProductLink.where(broken: nil).update_all(broken: false)
    change_column_null :product_links, :broken, false
  end
end
