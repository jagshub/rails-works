class RemoveCollectionIdsColumnFromBestOfPage < ActiveRecord::Migration
  def change
    remove_column :best_of_pages, :collection_ids, :integer, array: true
  end
end
