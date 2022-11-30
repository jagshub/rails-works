class CreateUpcomingPageSegmentSubscriberAssociations < ActiveRecord::Migration
  def change
    create_table :upcoming_page_segment_subscriber_associations do |t|
      t.integer :upcoming_page_segment_id, null: false
      t.integer :upcoming_page_subscriber_id, null: false
      t.timestamps null: false
    end

    add_foreign_key :upcoming_page_segment_subscriber_associations, :upcoming_page_segments
    add_foreign_key :upcoming_page_segment_subscriber_associations, :upcoming_page_subscribers

    add_index :upcoming_page_segment_subscriber_associations, [:upcoming_page_segment_id, :upcoming_page_subscriber_id], unique: true, name: 'upcoming_page_subscriber_assoc_segment_subscriber'
  end
end
