class ChangeNullOnPostsRelatedPostsCount < ActiveRecord::Migration[5.1]
  def change
    change_column_null :posts, :related_posts_count, false
  end
end
