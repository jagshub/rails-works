class ChangeCommentColumnName < ActiveRecord::Migration
  def change
    rename_column :comments, :in_reply_to_comment_id, :parent_comment_id
  end
end
