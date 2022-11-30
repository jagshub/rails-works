class AddFeaturedAndFeaturedPriorityToCollectionPosts < ActiveRecord::Migration
  def change
    add_column :collection_post_associations, :featured, :boolean, default: false, null: false
    add_column :collection_post_associations, :featured_priority, :integer, default: 0, null: false
  end
end
