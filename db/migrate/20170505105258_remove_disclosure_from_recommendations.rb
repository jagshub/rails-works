class RemoveDisclosureFromRecommendations < ActiveRecord::Migration
  def change
    remove_column :recommendations, :disclosure, :text
  end
end
