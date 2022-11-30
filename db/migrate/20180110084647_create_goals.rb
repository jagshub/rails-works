class CreateGoals < ActiveRecord::Migration[5.0]
  def change
    create_table :goals do |t|
      t.jsonb :title, null: false
      t.datetime :completed_at, index: true
      t.integer :comments_count, null: false, default: 0
      t.references :user, foreign_key: true, index: true, null: false

      t.timestamps null: false
    end

    add_column :users, :goals_count, :integer, null: false, default: 0
    add_column :users, :completed_goals_count, :integer, null: false, default: 0
  end
end
