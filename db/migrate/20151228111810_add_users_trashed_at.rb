class AddUsersTrashedAt < ActiveRecord::Migration
  def change
    add_column :users, :trashed_at, :timestamp, null: true
  end
end
