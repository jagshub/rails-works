class CreateSpamRules < ActiveRecord::Migration[5.1]
  def change
    create_table :spam_rules do |t|
      t.integer :filter_kind, null: false
      t.integer :checks_count, null: false, default: 0
      t.integer :false_positive_count, null: false, default: 0
      t.string :value
      t.references :spam_ruleset, foreign_key: true

      t.timestamps
    end

    add_index :spam_rules, %i(value filter_kind), unique: true
  end
end
