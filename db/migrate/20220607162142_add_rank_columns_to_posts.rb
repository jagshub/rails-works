class AddRankColumnsToPosts < ActiveRecord::Migration[6.1]
  def change
    add_column :posts, :daily_rank,   :integer, null: true
    add_column :posts, :weekly_rank,  :integer, null: true
    add_column :posts, :monthly_rank, :integer, null: true
  end
end
