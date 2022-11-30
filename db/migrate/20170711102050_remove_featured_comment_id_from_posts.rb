class RemoveFeaturedCommentIdFromPosts < ActiveRecord::Migration
  def change
    remove_column :posts, :featured_comment_id, :integer
  end
end
