class AddCounterCacheToUpcomingPageMessages < ActiveRecord::Migration[5.1]
  def change
    add_column :upcoming_page_messages, :sent_count, :integer
    add_column :upcoming_page_messages, :opened_count, :integer
    add_column :upcoming_page_messages, :clicked_count, :integer
    add_column :upcoming_page_messages, :failed_count, :integer

    change_column_default :upcoming_page_messages, :sent_count, 0
    change_column_default :upcoming_page_messages, :opened_count, 0
    change_column_default :upcoming_page_messages, :clicked_count, 0
    change_column_default :upcoming_page_messages, :failed_count, 0
  end
end
