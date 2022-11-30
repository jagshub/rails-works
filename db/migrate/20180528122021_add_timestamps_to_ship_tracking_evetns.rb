class AddTimestampsToShipTrackingEvetns < ActiveRecord::Migration[5.0]
  def change
    add_column :ship_tracking_events, :created_at, :datetime, null: true
    add_column :ship_tracking_events, :updated_at, :datetime, null: true

    execute 'UPDATE ship_tracking_events SET created_at = NOW(), updated_at = NOW();'

    change_column_null :ship_tracking_events, :created_at, false
    change_column_null :ship_tracking_events, :updated_at, false
  end
end
