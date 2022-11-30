class AddReviewsRatingToReviewables < ActiveRecord::Migration[6.1]
  def change
    add_column :posts,    :reviews_rating, :decimal, precision: 3, scale: 2, null: false, default: 0
    add_column :products, :reviews_rating, :decimal, precision: 3, scale: 2, null: false, default: 0
  end
end
