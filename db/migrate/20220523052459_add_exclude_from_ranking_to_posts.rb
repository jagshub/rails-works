class AddExcludeFromRankingToPosts < ActiveRecord::Migration[6.1]
  def change
    add_column :posts, :exclude_from_ranking, :boolean, default: false, null: false
  end
end
