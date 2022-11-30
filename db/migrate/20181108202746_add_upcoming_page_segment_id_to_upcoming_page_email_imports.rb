class AddUpcomingPageSegmentIdToUpcomingPageEmailImports < ActiveRecord::Migration[5.0]
  def change
    add_column :upcoming_page_email_imports, :upcoming_page_segment_id, :integer, null: true

    add_foreign_key :upcoming_page_email_imports, :upcoming_page_segments
  end
end
