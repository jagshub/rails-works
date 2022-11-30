class UpdatePriorityToNotNull < ActiveRecord::Migration[5.2]
  class SpamRuleset < ActiveRecord::Base
  end

  def change
    change_column_default :spam_rulesets, :priority, from: nil, to: 0
    SpamRuleset.where(priority: nil).update_all(priority: 0)
    change_column_null :spam_rulesets, :priority, false
  end
end
