class RemoveTopicFromDiscussionThreads < ActiveRecord::Migration[6.1]
  def change
    safety_assured { remove_column :discussion_threads, :topic }
  end
end
