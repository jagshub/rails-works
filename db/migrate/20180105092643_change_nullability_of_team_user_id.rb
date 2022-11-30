class ChangeNullabilityOfTeamUserId < ActiveRecord::Migration[5.0]
  def change
    change_column_null :teams, :user_id, false
    change_column_null :teams, :ship_subscription_id, true
  end
end
