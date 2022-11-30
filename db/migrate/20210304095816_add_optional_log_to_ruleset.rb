class AddOptionalLogToRuleset < ActiveRecord::Migration[5.1]
  def up
    add_column :spam_rulesets, :ignore_not_spam_log, :boolean

    change_column_default :spam_rulesets, :ignore_not_spam_log, false
  end

  def down
    remove_column :spam_rulesets, :ignore_not_spam_log
  end
end
