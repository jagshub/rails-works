class AddVotesCountToComments < ActiveRecord::Migration
  def change
    add_column :comments, :votes_count, :integer, null: false, default: 0
    add_column :comments, :credible_votes_count, :integer, null: false, default: 0
    add_index :comments, :credible_votes_count
  end
end
