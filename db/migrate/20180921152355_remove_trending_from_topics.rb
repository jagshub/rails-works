class RemoveTrendingFromTopics < ActiveRecord::Migration[5.0]
  def change
    remove_column :topics, :trending, :boolean, null: false, default: false
  end
end
