class RemoveGoalFromMakerActivity < ActiveRecord::Migration[5.1]
  def change
    remove_reference :maker_activities, :goal, foreign_key: true, null: true

    add_reference :maker_activities, :maker_group, foreign_key: true, null: true
  end
end
