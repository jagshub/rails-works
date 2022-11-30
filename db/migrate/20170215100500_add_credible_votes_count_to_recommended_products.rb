class AddCredibleVotesCountToRecommendedProducts < ActiveRecord::Migration
  def change
    add_column :recommended_products, :credible_votes_count, :integer, null: false, default: 0
    add_index :recommended_products, :credible_votes_count
  end
end
