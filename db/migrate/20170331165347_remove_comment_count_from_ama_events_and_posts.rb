class RemoveCommentCountFromAmaEventsAndPosts < ActiveRecord::Migration
  def change
    remove_column :ama_events, :comment_count, :integer
    remove_column :posts, :comment_count, :integer
  end
end
