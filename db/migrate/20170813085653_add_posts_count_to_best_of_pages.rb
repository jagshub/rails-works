class AddPostsCountToBestOfPages < ActiveRecord::Migration
  def change
    add_column :best_of_pages, :posts_count, :integer, null: false, default: 0
  end
end
