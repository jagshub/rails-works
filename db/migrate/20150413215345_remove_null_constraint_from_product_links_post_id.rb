class RemoveNullConstraintFromProductLinksPostId < ActiveRecord::Migration
  def change
    change_column_null :product_links, :post_id, true
  end
end
