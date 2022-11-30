class RenamePostsPublishedAtToFeaturedAt < ActiveRecord::Migration
  def change
    rename_column(:posts, :published_at, :featured_at)
  end
end
