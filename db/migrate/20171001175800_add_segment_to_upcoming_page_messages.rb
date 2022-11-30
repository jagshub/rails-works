class AddSegmentToUpcomingPageMessages < ActiveRecord::Migration
  def change
    add_column :upcoming_page_messages, :segment, :integer, default: 0, null: false
  end
end
