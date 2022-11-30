class AddHighlightedToRecommendations < ActiveRecord::Migration
  def change
    add_column :recommendations, :highlighted, :boolean, default: false
  end
end
