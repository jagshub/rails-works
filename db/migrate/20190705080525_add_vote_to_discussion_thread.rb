class AddVoteToDiscussionThread < ActiveRecord::Migration[5.1]
  def change
    add_column :discussion_threads, :votes_count, :integer, null: false, default: 0
    add_column :discussion_threads, :credible_votes_count, :integer, null: false, default: 0
  end
end
