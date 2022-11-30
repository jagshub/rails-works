class AddCurrentUntilToGoal < ActiveRecord::Migration[5.0]
  def change
    add_column :goals, :current_until, :datetime
  end
end
