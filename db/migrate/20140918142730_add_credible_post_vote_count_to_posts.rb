class AddCrediblePostVoteCountToPosts < ActiveRecord::Migration
  def up
    add_column :posts, :credible_post_votes_count, :integer, default: 0, null: false
    # Note(andreasklinger): We are defaulting all current posts to their latest votes state
    #    from there on the credible-check in the post_vote will increment/decrement correctly.
    Post.update_all('credible_post_votes_count = votes')
  end

  def down
    remove_column :posts, :credible_post_votes_count
  end
end
