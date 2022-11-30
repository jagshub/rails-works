class AddCredibleVotesIndexToPosts < ActiveRecord::Migration
  disable_ddl_transaction!
  def change
    add_index :posts, :credible_post_votes_count, algorithm: :concurrently
  end
end
