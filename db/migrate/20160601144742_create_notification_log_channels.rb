class CreateNotificationLogChannels < ActiveRecord::Migration
  def change
    create_table :notification_events do |t|
      t.integer :notification_id, null: false
      t.string :channel_name, null: false
      t.integer :status, null: false, default: 0
      t.text :failure_reason, null: true
      t.datetime :sent_at, null: true
    end

    add_foreign_key :notification_events, :notification_logs, column: :notification_id

    add_index :notification_events, %i(notification_id channel_name)
  end
end
