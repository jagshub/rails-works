class MakePostsScheduledAtNonNull < ActiveRecord::Migration[5.0]
  def change
    change_column_null :posts, :scheduled_at, false
  end
end
