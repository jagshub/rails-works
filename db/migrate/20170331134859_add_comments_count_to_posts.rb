class AddCommentsCountToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :comments_count, :integer, null: false, default: 0
    add_index :posts, :comments_count
  end
end
