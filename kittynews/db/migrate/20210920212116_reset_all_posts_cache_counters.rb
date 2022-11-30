class ResetAllPostsCacheCounters < ActiveRecord::Migration[6.1]
  def up
    Post.all.each do |post|
      Post.reset_counters(post.id, :votes)
    end
  end

  def down
    # no rollback needed
  end
end
