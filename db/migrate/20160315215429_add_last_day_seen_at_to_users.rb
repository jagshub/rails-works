class AddLastDaySeenAtToUsers < ActiveRecord::Migration
  disable_ddl_transaction!

  def change
    add_column :users, :last_day_seen_at, :datetime
    add_index :users, :last_day_seen_at, algorithm: :concurrently
  end
end
