# frozen_string_literal: true

# == Schema Information
#
# Table name: spam_action_logs
#
#  id                       :bigint(8)        not null, primary key
#  subject_type             :string           not null
#  subject_id               :bigint(8)        not null
#  user_id                  :bigint(8)        not null
#  spam                     :boolean          not null
#  false_positive           :boolean          default(FALSE), not null
#  action_taken_on_activity :string
#  action_taken_on_actor    :string
#  spam_ruleset_id          :bigint(8)        not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  reverted_at              :datetime
#  reverted_by_id           :bigint(8)
#
# Indexes
#
#  index_spam_action_logs_on_reverted_by_id               (reverted_by_id)
#  index_spam_action_logs_on_spam_ruleset_id              (spam_ruleset_id)
#  index_spam_action_logs_on_subject_type_and_subject_id  (subject_type,subject_id)
#  index_spam_action_logs_on_user_id                      (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (reverted_by_id => users.id)
#  fk_rails_...  (spam_ruleset_id => spam_rulesets.id)
#  fk_rails_...  (user_id => users.id)
#

class Spam::ActionLog < ApplicationRecord
  include Namespaceable

  after_create :refresh_counter

  SUBJECTS = [
    Vote,
    Comment,
    User,
    Review,
  ].freeze

  belongs_to_polymorphic :subject, allowed_classes: SUBJECTS
  belongs_to :user, class_name: '::User', inverse_of: :spam_action_logs
  belongs_to :ruleset, class_name: '::Spam::Ruleset', inverse_of: :action_logs, foreign_key: :spam_ruleset_id
  belongs_to :reverted_by, class_name: '::User', foreign_key: :reverted_by_id, inverse_of: :reverted_spam_actions, optional: true

  has_many :rule_logs, class_name: '::Spam::RuleLog', inverse_of: :action_log, foreign_key: :spam_action_log_id, dependent: :destroy
  has_many :reports, class_name: '::Spam::Report', inverse_of: :action_log, foreign_key: :spam_action_log_id, dependent: :destroy

  private

  def refresh_counter
    ruleset.refresh_checks_count
  end
end
