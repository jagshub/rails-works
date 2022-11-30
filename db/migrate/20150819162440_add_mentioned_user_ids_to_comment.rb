class AddMentionedUserIdsToComment < ActiveRecord::Migration
  def change
    add_column :comments, :mentioned_user_ids, :integer, array: true, default: []
  end
end
