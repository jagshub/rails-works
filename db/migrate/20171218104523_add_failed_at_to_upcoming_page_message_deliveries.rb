class AddFailedAtToUpcomingPageMessageDeliveries < ActiveRecord::Migration[5.0]
  def change
    add_column :upcoming_page_message_deliveries, :failed_at, :datetime, null: true
  end
end
