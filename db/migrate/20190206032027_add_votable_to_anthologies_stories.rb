class AddVotableToAnthologiesStories < ActiveRecord::Migration[5.0]
  def change
    add_column :anthologies_stories, :votes_count, :integer, null: false, default: 0
    add_column :anthologies_stories, :credible_votes_count, :integer, null: false, default: 0

    add_index :anthologies_stories, :credible_votes_count
  end
end
