class AddTrashedAtToTeams < ActiveRecord::Migration[5.0]
  def change
    add_column :teams, :trashed_at, :datetime, null: true
    add_index :teams, :trashed_at
  end
end
