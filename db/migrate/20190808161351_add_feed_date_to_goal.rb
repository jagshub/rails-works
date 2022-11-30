class AddFeedDateToGoal < ActiveRecord::Migration[5.1]
  def change
    add_column :goals, :feed_date, :date, null: true
  end
end
