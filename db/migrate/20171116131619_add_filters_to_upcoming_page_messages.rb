class AddFiltersToUpcomingPageMessages < ActiveRecord::Migration[5.0]
  def change
    add_column :upcoming_page_messages, :subscriber_filters, :jsonb, null: false, default: []
  end
end
