class CreateMakerGroups < ActiveRecord::Migration[5.0]
  def change
    create_table :maker_groups do |t|
      t.string :name, null: false
      t.integer :kind, null: false, default: 0, index: true
      t.integer :completed_goals_count, null: false, default: 0
      t.integer :goals_count, null: false, default: 0

      t.timestamps
    end

    add_belongs_to :goals, :maker_group, foreign_key: true, index: true
  end
end
