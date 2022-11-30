class AddPriorityToSpamRuleset < ActiveRecord::Migration[5.2]
  def change
    add_column :spam_rulesets, :priority, :integer, null: true
  end
end
