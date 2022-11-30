class RenameRatingsCountToReviewsWithRatingCount < ActiveRecord::Migration[6.1]
  def change
    safety_assured do 
      rename_column :posts, :ratings_count, :reviews_with_rating_count
      rename_column :products, :ratings_count, :reviews_with_rating_count
    end
  end
end
