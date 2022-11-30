class AddTopicsToBestOfPage < ActiveRecord::Migration
  def change
    add_column :best_of_pages, :topic_ids, :integer, array: true, default: []
    add_column :best_of_pages, :collection_ids, :integer, array: true, default: []
  end
end
