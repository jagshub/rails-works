class AddCommentsCountToRecommendations < ActiveRecord::Migration
  def change
    add_column :recommendations, :comments_count, :integer, null: false, default: 0
    add_index :recommendations, :comments_count
  end
end
