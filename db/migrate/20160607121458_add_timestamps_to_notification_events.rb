class AddTimestampsToNotificationEvents < ActiveRecord::Migration
  def change
    change_table :notification_events do |t|
      t.timestamps null: true
    end

    reversible { |d| d.up { execute 'UPDATE notification_events SET updated_at = NOW(), created_at = NOW();' } }

    change_column_null :notification_events, :created_at, false
    change_column_null :notification_events, :updated_at, false
  end
end
