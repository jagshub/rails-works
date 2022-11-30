class RemoveSegmentFromUpcomingPageMessages < ActiveRecord::Migration[5.0]
  def change
    remove_column :upcoming_page_messages, :segment
  end
end
