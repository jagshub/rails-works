class AddLayoutToUpcomingPageMessages < ActiveRecord::Migration[5.0]
  def change
    add_column :upcoming_page_messages, :layout, :integer, default: 0, null: false
    add_reference :upcoming_page_messages, :upcoming_page_survey, null: true
    add_foreign_key :upcoming_page_messages, :upcoming_page_surveys
  end
end
