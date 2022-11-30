class UpdateRepliesCountForComment < ActiveRecord::Migration[5.1]
  def up
    change_column :comments, :replies_count, :integer, null: false, default: 0
  end

  def down
    change_column :comments, :replies_count, :integer, null: true
  end
end
