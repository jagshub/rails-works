class AddSubscriberCountToCollections < ActiveRecord::Migration
  def change
    add_column :collections, :subscriber_count, :integer, null: false, default: 0
  end
end
