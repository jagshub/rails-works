class AddNotNullToIgnoreNotSpamLog < ActiveRecord::Migration[5.1]
  class Spam::Ruleset < ApplicationRecord; end

  def change
    Spam::Ruleset.update_all ignore_not_spam_log: false

    change_column_null :spam_rulesets, :ignore_not_spam_log, false
  end
end
