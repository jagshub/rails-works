class AddIndexToGoalCurrent < ActiveRecord::Migration[5.0]
  disable_ddl_transaction!

  def change
    add_index :goals, %i(user_id current), unique: true, where: :current, algorithm: :concurrently
  end
end
