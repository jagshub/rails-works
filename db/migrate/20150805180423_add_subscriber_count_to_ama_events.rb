class AddSubscriberCountToAmaEvents < ActiveRecord::Migration
  def change
    add_column :ama_events, :subscriber_count, :integer, null: false, default: 0
  end
end
