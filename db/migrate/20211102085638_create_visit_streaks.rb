class CreateVisitStreaks < ActiveRecord::Migration[6.1]
  def change
    create_table :visit_streaks do |t|
      t.references :user, null: false, index: true, foreign_key: true
      t.timestamp :started_at, null: false
      t.timestamp :ended_at, null: true
      t.timestamp :last_visit_at, null: false
      t.integer :duration, null: false, default: 1

      t.timestamps
    end
  end
end
