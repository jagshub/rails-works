class DropPostCommentChangeLogMediaTables < ActiveRecord::Migration[5.2]
  def change
    drop_table :post_media
    drop_table :comment_media
    drop_table :change_log_media
  end
end
