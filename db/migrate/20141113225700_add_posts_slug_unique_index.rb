class AddPostsSlugUniqueIndex < ActiveRecord::Migration
  def change
    execute 'commit'
    add_index :posts, :slug, unique: true, algorithm: :concurrently
    execute 'begin'
  end
end
