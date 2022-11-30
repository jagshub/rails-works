class AddInReplyToToComments < ActiveRecord::Migration
  def change
    add_column :comments, :in_reply_to_comment_id, :integer
  end
end
