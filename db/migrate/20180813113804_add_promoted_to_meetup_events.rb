class AddPromotedToMeetupEvents < ActiveRecord::Migration[5.0]
  def change
    add_column :meetup_events, :promoted, :boolean, null: false, default: false
  end
end
