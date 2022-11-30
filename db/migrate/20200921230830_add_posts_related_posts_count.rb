class AddPostsRelatedPostsCount < ActiveRecord::Migration[5.1]
  def up
    add_column :posts, :related_posts_count, :integer
  end
end
