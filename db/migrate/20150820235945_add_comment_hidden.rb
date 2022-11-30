class AddCommentHidden < ActiveRecord::Migration
  class Comment < ApplicationRecord
    enum state: {
      visible: 0,
      sandboxed: 10,
      sticky: 100
    }
  end

  def change
    add_column :comments, :state, :integer, default: Comment.states[:visible], null: false

    Comment.where(sticky: true).update_all(state: Comment.states[:sticky])
  end
end
