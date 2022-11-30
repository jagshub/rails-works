class CreateUserVisitStreakReminders < ActiveRecord::Migration[6.1]
  def change
    create_table :user_visit_streak_reminders do |t|
      t.references :user,  null:false

      t.integer :streak_duration
      t.timestamps
    end
  end
end
