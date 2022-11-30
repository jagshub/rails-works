class AddScoreMultiplierToRecommendedProducts < ActiveRecord::Migration
  def change
    add_column :recommended_products, :score_multiplier, :float, :precision => 3, :scale => 2, :default => 1.00
  end
end
