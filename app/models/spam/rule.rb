# frozen_string_literal: true

# == Schema Information
#
# Table name: spam_rules
#
#  id                   :bigint(8)        not null, primary key
#  filter_kind          :integer          not null
#  checks_count         :integer          default(0), not null
#  false_positive_count :integer          default(0), not null
#  value                :string
#  spam_ruleset_id      :bigint(8)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_spam_rules_on_spam_ruleset_id                            (spam_ruleset_id)
#  index_spam_rules_on_value_and_filter_kind_and_spam_ruleset_id  (value,filter_kind,spam_ruleset_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (spam_ruleset_id => spam_rulesets.id)
#

class Spam::Rule < ApplicationRecord
  include Namespaceable
  include ExplicitCounterCache

  extension NullifyEmptyString, columns: :value

  before_validation :format_value

  belongs_to :ruleset, class_name: '::Spam::Ruleset', inverse_of: :rules, foreign_key: :spam_ruleset_id

  has_many :rule_logs, class_name: '::Spam::RuleLog', inverse_of: :rule, foreign_key: :spam_rule_id, dependent: :destroy

  enum filter_kind: SpamChecks.filter_kind_enums

  explicit_counter_cache :false_positive_count, -> { rule_logs.where(false_positive: true) }

  validates :filter_kind, presence: true
  validates :value, uniqueness: { scope: %i(filter_kind spam_ruleset_id) }

  def refresh_checks_count
    ::Spam::Rule.increment_counter(:checks_count, id)
  end

  private

  def format_value
    return if value.nil?

    self.value = SpamChecks.format_filter_value(filter_kind, value)
  rescue ArgumentError => e
    errors.add(:value, e.message)
  end
end
