class AddPriorityToShoutouts < ActiveRecord::Migration[5.0]
  def change
    add_column :shoutouts, :priority, :integer, default: 0, null: false
    add_index :shoutouts, :trashed_at
  end
end
