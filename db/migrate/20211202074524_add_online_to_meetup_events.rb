class AddOnlineToMeetupEvents < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      add_column :meetup_events, :online, :boolean, null: false, default: false
      change_column :meetup_events, :city, :string, null: true
      change_column :meetup_events, :country, :string, null: true
    end
  end
end
