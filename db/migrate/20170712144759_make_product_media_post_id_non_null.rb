class MakeProductMediaPostIdNonNull < ActiveRecord::Migration
  def change
    change_column_null :product_media, :post_id, false
  end
end
