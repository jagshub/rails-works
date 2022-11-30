class AddTrendingToGoal < ActiveRecord::Migration[5.1]
  def change
    add_column :goals, :trending_at, :date
  end
end
