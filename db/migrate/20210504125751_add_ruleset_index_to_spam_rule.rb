class AddRulesetIndexToSpamRule < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def up
    add_index :spam_rules, %i(value filter_kind spam_ruleset_id), unique: true, algorithm: :concurrently

    remove_index :spam_rules, %i(value filter_kind)
  end

  def down
    add_index :spam_rules, %i(value filter_kind), unique: true, algorithm: :concurrently

    remove_index :spam_rules, %i(value filter_kind spam_ruleset_id)
  end
end
