class AddDisclosedToRecommendations < ActiveRecord::Migration
  def change
    add_column :recommendations, :disclosed, :boolean, default: false
  end
end
