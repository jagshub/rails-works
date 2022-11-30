class AddHelpfulRecommendationsCountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :helpful_recommendations_count, :integer, null: false, default: 0
  end
end
