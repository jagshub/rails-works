class RemoveReplyToUpcomingPageQuestionIdUpcomingPageSegmentIdFromMessages < ActiveRecord::Migration[5.0]
  def change
    remove_column :upcoming_page_messages, :reply_to
    remove_column :upcoming_page_messages, :upcoming_page_segment_id
  end
end
