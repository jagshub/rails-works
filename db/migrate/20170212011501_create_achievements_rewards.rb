class CreateAchievementsRewards < ActiveRecord::Migration
  def change
    create_table :achievements_rewards do |t|
      t.string :name
      t.string :description
      t.string :slug

      t.timestamps null: false
    end
  end
end
