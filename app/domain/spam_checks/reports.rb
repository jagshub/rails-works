# frozen_string_literal: true

module SpamChecks::Reports
  extend self

  def add_new(action_log:, to_check:)
    action_log.reports.new(
      user: action_log.user,
      check: to_check,
    )
  end

  def mark_as_false_positive(report, handled_by)
    action_log = report.action_log

    ::SpamChecks::RevertAction.revert(action_log, handled_by)
  end

  def mark_as_spam(report, handled_by)
    ActiveRecord::Base.transaction do
      action_log = report.action_log

      ::SpamChecks::Activity.mark_as_spam(action_log.subject)
      ::SpamChecks::Activity.mark_as_spam(action_log.user)

      action_log.reports.find_each do |spam_report|
        spam_report.update! handled_by: handled_by, action_taken: :marked_spam
      end
    end
  end
end
