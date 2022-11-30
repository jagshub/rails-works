class BackfillCounterCacheForUpcomingPageMessages < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!
  class UpcomingPageMessage < ActiveRecord::Base; end

  def change
    UpcomingPageMessage.in_batches do |relation|
      relation.update_all(
        sent_count: 0,
        opened_count: 0,
        clicked_count: 0,
        failed_count: 0,
      )
      sleep(0.01) # throttle
    end

    change_column_null :upcoming_page_messages, :sent_count, null: false
    change_column_null :upcoming_page_messages, :opened_count, null: false
    change_column_null :upcoming_page_messages, :clicked_count, null: false
    change_column_null :upcoming_page_messages, :failed_count, null: false
  end
end
