class RemoveProductRequestKindDefault < ActiveRecord::Migration
  def change
    change_column_default(:product_requests, :kind, nil)
  end
end
