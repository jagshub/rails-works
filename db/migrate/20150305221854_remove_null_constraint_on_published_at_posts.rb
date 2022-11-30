class RemoveNullConstraintOnPublishedAtPosts < ActiveRecord::Migration
  def change
    change_column_null(:posts, :published_at, true)
  end
end
