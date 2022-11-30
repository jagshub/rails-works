class CreateAchievements < ActiveRecord::Migration
  def change
    create_table :achievements do |t|
      t.string :name, null: false
      t.string :slug, null: false, index: true
      t.string :description, null: false
      t.string :rule_set_name, null: false
      t.integer :rule_set_option

      t.timestamps null: false
    end
  end
end
