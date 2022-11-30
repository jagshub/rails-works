class AddVotesCountAndCredibleVotesCountToGoals < ActiveRecord::Migration[5.0]
  def change
    add_column :goals, :votes_count, :integer, null: false, default: 0
    add_column :goals, :credible_votes_count, :integer, null: false, default: 0
  end
end
