class CreateSpamRulesets < ActiveRecord::Migration[5.1]
  def change
    create_table :spam_rulesets do |t|
      t.string :name, null: false
      t.text :note
      t.references :added_by, foreign_key: { to_table: :users }, null: true
      t.boolean :active, null: false, default: true
      t.integer :for_activity, null: false
      t.integer :action_on_activity, null: false
      t.integer :action_on_actor, null: false
      t.integer :checks_count, null: false, default: 0
      t.integer :false_positive_count, null: false, default: 0

      t.timestamps
    end

    add_index :spam_rulesets, %i(for_activity active)
  end
end
