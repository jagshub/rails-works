class CreateUpcomingPageMessageDeliveries < ActiveRecord::Migration[5.0]
  def change
    create_table :upcoming_page_message_deliveries do |t|
      t.references :upcoming_page_message, index: false, null: false
      t.references :upcoming_page_subscriber, index: false, null: false
      t.datetime :sent_at, null: true
      t.datetime :opened_at, null: true
      t.datetime :clicked_at, null: true
      t.timestamps null: false
    end

    add_index :upcoming_page_message_deliveries, :upcoming_page_message_id, name: 'index_upcoming_page_message_deliveries_on_message_id'
    add_index :upcoming_page_message_deliveries, :upcoming_page_subscriber_id, name: 'index_upcoming_page_message_deliveries_on_subscriber_id'
    add_index :upcoming_page_message_deliveries, [:upcoming_page_message_id, :upcoming_page_subscriber_id], unique: true, name: 'index_upcoming_page_message_deliveries_on_message_subscriber'

    add_foreign_key :upcoming_page_message_deliveries, :upcoming_page_messages
    add_foreign_key :upcoming_page_message_deliveries, :upcoming_page_subscribers
  end
end
