class AddCurrentToGoal < ActiveRecord::Migration[5.0]
  def change
    add_column :goals, :current, :boolean, default: false, null: false
  end
end
