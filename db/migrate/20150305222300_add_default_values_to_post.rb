class AddDefaultValuesToPost < ActiveRecord::Migration
  def change
    change_column_default(:posts, :hide, false)
    change_column_default(:posts, :votes, 0)
    change_column_default(:posts, :credible_post_votes_count, 0)
    change_column_default(:posts, :comment_count, 0)
  end
end
