class AddReviewCountsToPost < ActiveRecord::Migration
  def change
    add_column :posts, :reviews_count, :integer, default: 0, null: false
    add_column :posts, :positive_reviews_count, :integer, default: 0, null: false
    add_column :posts, :neutral_reviews_count, :integer, default: 0, null: false
    add_column :posts, :negative_reviews_count, :integer, default: 0, null: false
  end
end
