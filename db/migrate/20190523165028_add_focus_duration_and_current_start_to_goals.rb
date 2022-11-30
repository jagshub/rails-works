class AddFocusDurationAndCurrentStartToGoals < ActiveRecord::Migration[5.1]
  def change
    add_column :goals, :focused_duration, :integer, null: true, default: 0
    add_column :goals, :current_started, :datetime, null: true
  end
end
