class AddCountryIndexToMeetupEvents < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :meetup_events, :country, algorithm: :concurrently
    add_index :meetup_events, :city, algorithm: :concurrently
    add_index :meetup_events, :date, algorithm: :concurrently
  end
end
