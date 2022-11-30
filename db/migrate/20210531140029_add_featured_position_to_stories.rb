class AddFeaturedPositionToStories < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_column :anthologies_stories, :featured_position, :integer, null: true

    add_index :anthologies_stories, :featured_position, where: 'featured_position IS NOT NULL', unique: true, algorithm: :concurrently
  end
end
