class AddDueAtToGoals < ActiveRecord::Migration[5.0]
  def change
    add_column :goals, :due_at, :date, null: true
    add_index :goals, :due_at
  end
end
