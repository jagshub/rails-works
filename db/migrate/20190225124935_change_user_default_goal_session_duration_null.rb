class ChangeUserDefaultGoalSessionDurationNull < ActiveRecord::Migration[5.0]
  def change
    change_column_default :users, :default_goal_session_duration, from: nil, to: 25
    change_column_null :users, :default_goal_session_duration, false
  end
end
