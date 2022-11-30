class AddCommentsCountToReview < ActiveRecord::Migration
  def change
    add_column :reviews, :comments_count, :integer, null: false, default: 0
  end
end
