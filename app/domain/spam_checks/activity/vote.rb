# frozen_string_literal: true

class SpamChecks::Activity::Vote < SpamChecks::Activity::Base
  def initialize(vote, request_info)
    super(vote, request_info)
  end

  def actor
    @record.user
  end

  def mark_as_spam
    @record.update!(
      sandboxed: sandboxed?,
      credible: false,
    )

    @record.subject.refresh_all_vote_counts if @record.subject.respond_to?(:refresh_all_vote_counts)
  end

  def revert_action_taken
    @record.update! sandboxed: false, credible: true

    @record.subject.refresh_all_vote_counts if @record.subject.respond_to?(:refresh_all_vote_counts)
  end

  def skip_spam_check?
    false
  end

  private

  NO_SANDBOX_CHECKS = ['NoClickThrough', 'UserTooYoung'].freeze

  # Note(Rahul): We are doing this to mark vote as non-credible alone
  #              when legacy custom vote filter is used!
  def sandboxed?
    return true if @action_log.blank? || @action_log.ruleset.rules.pluck(:filter_kind) != ['custom_vote_filter']

    failed_checks = @action_log.rule_logs.first.checked_data.dig('checks_info', 'failed_checks')
    return true if failed_checks.blank?

    failed_checks.sort != NO_SANDBOX_CHECKS.sort
  end
end
