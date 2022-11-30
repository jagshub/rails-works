class AddScoreMultiplierToReview < ActiveRecord::Migration
  def change
    add_column :reviews, :score_multiplier, :float, precision: 3, scale: 2, default: 1.00, null: false
  end
end
