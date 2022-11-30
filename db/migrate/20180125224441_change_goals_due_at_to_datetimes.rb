class ChangeGoalsDueAtToDatetimes < ActiveRecord::Migration[5.0]
  def change
    change_column :goals, :due_at, :datetime
  end
end
