class RemoveLastDaySeenAtFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :last_day_seen_at, :datetime
  end
end
