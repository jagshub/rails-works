class CreateSpamRuleLogs < ActiveRecord::Migration[5.1]
  def change
    create_table :spam_rule_logs do |t|
      t.references :spam_ruleset, foreign_key: true, null: false
      t.references :spam_action_log, foreign_key: true, null: false
      t.references :spam_rule, foreign_key: true, null: false
      t.jsonb :checked_data, null: false
      t.references :spam_filter_value, foreign_key: true, null: true
      t.string :custom_value
      t.boolean :false_positive, null: false, default: false
      t.boolean :spam, null: false

      t.timestamps
    end
  end
end
