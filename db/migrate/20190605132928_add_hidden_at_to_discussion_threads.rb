class AddHiddenAtToDiscussionThreads < ActiveRecord::Migration[5.1]
  def change
    add_column :discussion_threads, :hidden_at, :datetime

    add_index :discussion_threads, :hidden_at
  end
end
