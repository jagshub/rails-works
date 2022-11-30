# frozen_string_literal: true

module SpamChecks
  extend self

  def sandbox_trashed_user_votes(trashed_user)
    SpamChecks::Admin::SandboxTrashedUserVotesWorker.perform_later trashed_user
  end

  def track_same_browser_multiple_logins(previous_user_id:, current_user:, request_info:)
    return if previous_user_id == current_user.id

    SpamChecks::SignIn::TrackSameBrowserWorker.perform_later previous_user_id, current_user, request_info
  end

  def filter_kind_enums
    SpamChecks::Filter.model_enums
  end

  def admin_create_filter_value(inputs)
    SpamChecks::Admin::CreateFilterValue.call inputs
  end

  def check_vote(vote)
    ::SpamChecks::CheckWorker.perform_later vote
  end

  def check_comment(comment, request_info)
    ::SpamChecks::CheckWorker.perform_later comment, request_info
  end

  def check_review(review, request_info)
    ::SpamChecks::CheckWorker.perform_later review, request_info
  end

  def check_user_signup(user)
    ::SpamChecks::CheckWorker.perform_later user
  end

  def revert_action(log, current_user)
    ::SpamChecks::RevertAction.revert(log, current_user)
  end

  def revert_manual_log(log, current_user, reason)
    ::SpamChecks::Admin::RevertManualLogWorker.perform_now log, current_user, reason
  end

  def mark_user_as_bad_actor(user:, handled_by:, activity: nil, reason: nil)
    SpamChecks::Admin::UserMarkAsBadActor.call user, handled_by, activity, reason
  end

  def mark_user_as_spammer(user:, handled_by:, activity: nil, reason: nil)
    SpamChecks::Admin::UserManualMarkAsSpammerWorker.perform_later user, handled_by, activity, reason
  end

  def mark_vote_as_spam(vote:, handled_by:, reason:)
    SpamChecks::Admin::VoteManualMarkAsSpamWorker.perform_later vote, handled_by, reason
  end

  def mark_report_as_spam(report, handled_by)
    SpamChecks::Admin::HandleReportWorker.perform_now report, handled_by, :mark_as_spam
  end

  def mark_report_as_false_positive(report, handled_by)
    SpamChecks::Admin::HandleReportWorker.perform_now report, handled_by, :mark_as_false_positive
  end

  def admin_dashboard
    SpamChecks::Admin::Dashboard
  end

  def format_filter_value(filter, value)
    SpamChecks::Filter.format_filter_value(filter, value)
  end

  def report_reason(action_log)
    ::SpamChecks::Filter.report_reason(action_log)
  end
end
