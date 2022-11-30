class AddReviewsCountToProducts < ActiveRecord::Migration[6.1]
  def change
    add_column :products, :reviews_count,           :integer, null: false, default: 0
    add_column :products, :reviews_with_body_count, :integer, null: false, default: 0
    add_column :products, :ratings_count,           :integer, null: false, default: 0

    add_column :products, :positive_reviews_count, :integer, null: false, default: 0
    add_column :products, :negative_reviews_count, :integer, null: false, default: 0
    add_column :products, :neutral_reviews_count,  :integer, null: false, default: 0
  end
end
