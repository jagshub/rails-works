class AddCommentToReview < ActiveRecord::Migration[5.1]
  def change
    add_reference :reviews, :comment, foreign_key: true, index: true, null: true
  end
end
