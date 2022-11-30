# frozen_string_literal: true

# == Schema Information
#
# Table name: spam_rulesets
#
#  id                   :bigint(8)        not null, primary key
#  name                 :string           not null
#  note                 :text
#  added_by_id          :bigint(8)
#  active               :boolean          default(TRUE), not null
#  for_activity         :integer          not null
#  action_on_activity   :integer          not null
#  action_on_actor      :integer          not null
#  checks_count         :integer          default(0), not null
#  false_positive_count :integer          default(0), not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  ignore_not_spam_log  :boolean          default(FALSE), not null
#  priority             :integer          default(0), not null
#
# Indexes
#
#  index_spam_rulesets_on_added_by_id              (added_by_id)
#  index_spam_rulesets_on_for_activity_and_active  (for_activity,active)
#
# Foreign Keys
#
#  fk_rails_...  (added_by_id => users.id)
#

class Spam::Ruleset < ApplicationRecord
  include Namespaceable
  include ExplicitCounterCache

  belongs_to :added_by, class_name: '::User', optional: true, inverse_of: :spam_rulesets

  has_many :rules, class_name: '::Spam::Rule', foreign_key: :spam_ruleset_id, inverse_of: :ruleset, dependent: :destroy
  has_many :action_logs, class_name: '::Spam::ActionLog', foreign_key: :spam_ruleset_id, inverse_of: :ruleset, dependent: :destroy
  has_many :rule_logs, class_name: '::Spam::RuleLog', inverse_of: :ruleset, foreign_key: :spam_ruleset_id, dependent: :destroy

  explicit_counter_cache :false_positive_count, -> { action_logs.where(false_positive: true) }

  accepts_nested_attributes_for :rules, allow_destroy: true

  # Note(Rahul): When you add new activity make sure the value is snake case of the model name
  #             Eg: Discussion::Thread -> discussion_thread
  #                 Vote -> vote
  enum for_activity: {
    vote: 0,
    comment: 1,
    user: 2, # Note(Rahul): This refers to signup
    review: 3,
  }

  enum action_on_activity: {
    mark_activity_spam: 0,
    report_activity: 1,
  }

  enum action_on_actor: {
    mark_actor_spam: 0,
    report_actor: 1,
  }

  validates :name, presence: true
  validates :active, inclusion: { in: [true, false] }
  validates :for_activity, presence: true
  validates :action_on_activity, presence: true
  validates :action_on_actor, presence: true

  scope :by_priority, -> { order('priority DESC, id') }

  def refresh_checks_count
    ::Spam::Ruleset.increment_counter(:checks_count, id)
  end
end
