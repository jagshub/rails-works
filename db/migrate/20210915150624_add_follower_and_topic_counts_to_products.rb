class AddFollowerAndTopicCountsToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :topics_count,    :integer, null: false, default: 0
    add_column :products, :followers_count, :integer, null: false, default: 0
  end
end
