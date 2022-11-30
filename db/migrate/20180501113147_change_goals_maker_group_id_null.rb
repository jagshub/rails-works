class ChangeGoalsMakerGroupIdNull < ActiveRecord::Migration[5.0]
  def change
    change_column_null :goals, :maker_group_id, false
  end
end
