class CollectionPostHighlitedItemDescription < ActiveRecord::Migration
  def change
    add_column :collection_post_associations, :description, :text
  end
end
