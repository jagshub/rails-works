class CreateMakerActivities < ActiveRecord::Migration[5.1]
  def change
    create_table :maker_activities do |t|
      t.integer :activity_type, default: 0, null: false
      t.references :goal, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end

     add_index :maker_activities, :created_at
  end
end
