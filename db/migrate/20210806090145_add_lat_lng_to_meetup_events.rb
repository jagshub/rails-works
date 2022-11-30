class AddLatLngToMeetupEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :meetup_events, :lat, :string, null: true
    add_column :meetup_events, :lng, :string, null: true
  end
end
