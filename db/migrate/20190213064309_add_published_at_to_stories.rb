class AddPublishedAtToStories < ActiveRecord::Migration[5.0]
  def change
    add_column :anthologies_stories, :published_at, :datetime
  end
end
