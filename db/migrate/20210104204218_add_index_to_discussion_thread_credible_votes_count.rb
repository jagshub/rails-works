class AddIndexToDiscussionThreadCredibleVotesCount < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def change
    add_index :discussion_threads, :credible_votes_count, algorithm: :concurrently
  end
end
