# frozen_string_literal: true

# == Schema Information
#
# Table name: spam_rule_logs
#
#  id                   :bigint(8)        not null, primary key
#  spam_ruleset_id      :bigint(8)        not null
#  spam_action_log_id   :bigint(8)        not null
#  spam_rule_id         :bigint(8)        not null
#  checked_data         :jsonb            not null
#  spam_filter_value_id :bigint(8)
#  custom_value         :string
#  false_positive       :boolean          default(FALSE), not null
#  spam                 :boolean          not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_spam_rule_logs_on_spam_action_log_id    (spam_action_log_id)
#  index_spam_rule_logs_on_spam_filter_value_id  (spam_filter_value_id)
#  index_spam_rule_logs_on_spam_rule_id          (spam_rule_id)
#  index_spam_rule_logs_on_spam_ruleset_id       (spam_ruleset_id)
#
# Foreign Keys
#
#  fk_rails_...  (spam_action_log_id => spam_action_logs.id)
#  fk_rails_...  (spam_filter_value_id => spam_filter_values.id)
#  fk_rails_...  (spam_rule_id => spam_rules.id)
#  fk_rails_...  (spam_ruleset_id => spam_rulesets.id)
#

class Spam::RuleLog < ApplicationRecord
  include Namespaceable

  after_create :refresh_counter

  belongs_to :ruleset, class_name: '::Spam::Ruleset', foreign_key: :spam_ruleset_id, inverse_of: :rule_logs
  belongs_to :action_log, class_name: '::Spam::ActionLog', foreign_key: :spam_action_log_id, inverse_of: :rule_logs
  belongs_to :rule, class_name: '::Spam::Rule', inverse_of: :rule_logs, foreign_key: :spam_rule_id
  belongs_to :filter_value, class_name: '::Spam::FilterValue', inverse_of: :rule_logs, optional: true, foreign_key: :spam_filter_value_id

  private

  def refresh_counter
    rule.refresh_checks_count
  end
end
