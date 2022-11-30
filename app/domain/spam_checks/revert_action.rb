# frozen_string_literal: true

module SpamChecks::RevertAction
  extend self

  def revert(action_log, reverted_by)
    return if action_log.reverted_at.present?

    subject = action_log.subject

    ActiveRecord::Base.transaction do
      ::SpamChecks::Activity.revert_action_taken(subject) unless subject.is_a? User

      ::SpamChecks::Activity.revert_action_taken(action_log.user) if action_log.ruleset.mark_actor_spam?

      mark_as_false_positive(action_log, reverted_by)
    end
  end

  private

  def mark_as_false_positive(action_log, reverted_by)
    action_log.update! false_positive: true, reverted_by: reverted_by, reverted_at: Time.zone.now
    action_log.ruleset.refresh_false_positive_count

    action_log.rule_logs.includes(:rule).where(spam: action_log.spam).find_each do |rule_log|
      rule_log.update! false_positive: true
      rule_log.rule.refresh_false_positive_count
    end

    action_log.reports.find_each do |spam_report|
      spam_report.update! handled_by: reverted_by, action_taken: :marked_false_positive
    end
  end
end
