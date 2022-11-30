class AddSubscribersCountToTopics < ActiveRecord::Migration
  def change
    add_column :topics, :subscribers_count, :integer, null: false, default: 0
  end
end
