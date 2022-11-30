class CreateStreamFeedItems < ActiveRecord::Migration[5.1]
  def change
    create_table :stream_feed_items do |t|
      t.string :verb, null: false
      t.integer :actor_ids, array: true, default: [], null: false
      t.integer :object_ids, array: true, default: [], null: false

      t.references :receiver, foreign_key: { to_table: :users }, null: false
      t.references :target, polymorphic: true, null: false

      t.datetime :seen_at, null: true
      t.datetime :last_occurrence_at, null: false

      t.timestamps null: false
    end

    add_index :stream_feed_items, :object_ids, using: 'gin'
    add_index :stream_feed_items, :seen_at
    add_index :stream_feed_items, :last_occurrence_at
    add_index :stream_feed_items, :verb
  end
end
