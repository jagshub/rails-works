class AddRejectedAtToUpcomingEvents < ActiveRecord::Migration[6.1]
  def change
    add_column :upcoming_events, :rejected_at, :datetime
  end
end
