class AddUpcomingPageSegmentIdToUpcomingPageMessages < ActiveRecord::Migration
  def change
    add_reference :upcoming_page_messages, :upcoming_page_segment, index: true
    add_foreign_key :upcoming_page_messages, :upcoming_page_segments
  end
end
