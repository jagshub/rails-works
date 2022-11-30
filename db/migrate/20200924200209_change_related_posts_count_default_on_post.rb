class ChangeRelatedPostsCountDefaultOnPost < ActiveRecord::Migration[5.1]
  def change
    change_column_default :posts, :related_posts_count, 0
  end
end
