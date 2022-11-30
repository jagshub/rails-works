class RemoveIgnoredVotesCountColumnsFromPost < ActiveRecord::Migration[5.0]
  def change
    remove_index :posts, :credible_post_votes_count

    remove_column :posts, :votes
    remove_column :posts, :credible_post_votes_count
  end
end
