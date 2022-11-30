class AddNonNullToDiscussionThreadSlug < ActiveRecord::Migration[5.1]
  def change
    change_column_null :discussion_threads, :slug, false
  end
end
