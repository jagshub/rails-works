class RemoveCategories < ActiveRecord::Migration
  def change
    remove_column :posts, :category_id
    remove_column :ama_events, :category_id
    remove_column :collections, :category_id
    drop_table :categories
  end
end
