class AddDefaultGoalSessionDurationToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :default_goal_session_duration, :integer
  end
end
