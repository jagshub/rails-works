class AddHandpickedCollectionIdsToBestOfPages < ActiveRecord::Migration
  def change
    add_column :best_of_pages, :handpicked_collection_ids, :integer, array: true, default: []
  end
end
