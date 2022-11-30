class AddApprovedByToMeetupEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :meetup_events, :approved_by, :string, null: true
  end
end
