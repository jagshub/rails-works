class CreateOnboardingTasks < ActiveRecord::Migration[5.1]
  def change
    create_table :onboarding_tasks do |t|
      t.string :task, null: false
      t.references :user, foreign_key: true, index: true, null: false
      t.datetime :completed_at, null: true

      t.timestamps
    end

    add_index :onboarding_tasks, [:user_id, :task], unique: true
  end
end
