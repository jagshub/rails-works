class ChangeUpcomingEventColumnsToNonNull < ActiveRecord::Migration[6.1]
  def change
    change_column_null :upcoming_events, :description, false
    change_column_null :upcoming_events, :banner_uuid, false
  end
end
