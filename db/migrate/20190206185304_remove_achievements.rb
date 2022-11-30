class RemoveAchievements < ActiveRecord::Migration[5.0]
  def change
    drop_table :achievements_user_reward_associations
    drop_table :achievements_rewards
    drop_table :achievements
  end
end
