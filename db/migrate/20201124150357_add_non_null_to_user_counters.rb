class AddNonNullToUserCounters < ActiveRecord::Migration[5.1]
  def change
    change_column_null :users, :comments_count, false
    change_column_null :users, :posts_count, false
    change_column_null :users, :product_makers_count, false
  end
end
