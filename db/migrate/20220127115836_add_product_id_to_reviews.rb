class AddProductIdToReviews < ActiveRecord::Migration[6.1]
  def change
    add_column :reviews, :product_id, :bigint, null: true
  end
end
