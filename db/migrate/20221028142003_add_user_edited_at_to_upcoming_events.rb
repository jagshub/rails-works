class AddUserEditedAtToUpcomingEvents < ActiveRecord::Migration[6.1]
  def change
    add_column :upcoming_events, :user_edited_at, :timestamp, null: true
  end
end
