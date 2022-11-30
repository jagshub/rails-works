class AddAttrsToStreamFeedItems < ActiveRecord::Migration[5.1]
  def change
    add_column :stream_feed_items, :data, :jsonb
    add_column :stream_feed_items, :connecting_text, :string, null: false

    rename_column :stream_feed_items, :object_ids, :action_objects
    change_column :stream_feed_items, :action_objects, :string, array: true, default: []
  end
end
