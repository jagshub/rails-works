class MakeReceivedAtInStreamEventsNonNullable < ActiveRecord::Migration[5.1]
  def change
    change_column_null :stream_events, :received_at, false
  end
end
