class RemoveVotesFromCollections < ActiveRecord::Migration[5.0]
  def change
    remove_column :collections, :votes_count
    remove_column :collections, :credible_votes_count
  end
end
