class CreateAchievementsUserRewardAssociations < ActiveRecord::Migration
  def change
    create_table :achievements_user_reward_associations do |t|
      t.belongs_to :user, foreign_key: true
      t.belongs_to :achievements_reward, foreign_key: true

      t.column :created_at, :datetime, null: false
    end

    add_index :achievements_user_reward_associations, [:user_id, :achievements_reward_id], unique: true, name: 'index_achievements_user_reward_assoc_on_user_id_and_reward_id'
  end
end
