class AddCredibleVotesCountToRecommendations < ActiveRecord::Migration
  def change
    add_column :recommendations, :credible_votes_count, :integer, null: false, default: 0
    add_index :recommendations, :credible_votes_count
  end
end
