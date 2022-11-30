class AddFeaturedCommentIdToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :featured_comment_id, :integer
  end
end
