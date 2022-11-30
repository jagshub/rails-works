class RemoveUnusedCollectionColumns < ActiveRecord::Migration
  def change
    remove_column :collections, :color
    remove_column :collections, :sorting_type
    remove_column :collection_post_associations, :description
  end
end
