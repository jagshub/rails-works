class AddKarmaPointsToUsers < ActiveRecord::Migration[5.1]
  def change
    safety_assured do
      add_column :users, :karma_points, :integer, null: true
      add_column :users, :karma_points_updated_at, :datetime, null: true
    end
  end
end
