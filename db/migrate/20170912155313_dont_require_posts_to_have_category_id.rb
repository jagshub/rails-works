class DontRequirePostsToHaveCategoryId < ActiveRecord::Migration
  def change
    remove_foreign_key :posts, :category
    remove_foreign_key :collections, :category

    change_column_default :posts, :category_id, 1
    change_column_default :ama_events, :category_id, 1
    change_column_default :collections, :category_id, 1
  end
end
