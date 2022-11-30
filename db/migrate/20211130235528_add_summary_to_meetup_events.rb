class AddSummaryToMeetupEvents < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      add_column :meetup_events, :official, :boolean, null: false, default: false
      add_column :meetup_events, :summary, :string, null: true
    end
  end
end
