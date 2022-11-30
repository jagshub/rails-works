class DropUserAchievementAssociations < ActiveRecord::Migration[5.1]
  def change
    drop_table :user_achievement_associations
  end
end
