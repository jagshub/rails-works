class RemoveUnusedCounterColumns < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      remove_column :posts, :positive_reviews_count
      remove_column :posts, :negative_reviews_count
      remove_column :posts, :neutral_reviews_count

      remove_column :products, :positive_reviews_count
      remove_column :products, :negative_reviews_count
      remove_column :products, :neutral_reviews_count
    end
  end
end
