class AddMeetupEventToNewsletter < ActiveRecord::Migration[5.0]
  def change
    add_column :newsletters, :meetup_event, :jsonb
  end
end
