class AddFollowersCountToTopics < ActiveRecord::Migration
  def change
    add_column :topics, :followers_count, :integer, null: false, default: 0
  end
end
