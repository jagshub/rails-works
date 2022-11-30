class AddTrendingFeaturedToDiscussionThread < ActiveRecord::Migration[5.1]
  def change
    add_column :discussion_threads, :featured_at, :date
    add_column :discussion_threads, :trending_at, :date
  end
end
