class AddIdsToCommentVote < ActiveRecord::Migration
  def change
    add_column :comment_votes, :user_id, :integer, null: false
    add_column :comment_votes, :comment_id, :integer, null: false
  end
end
