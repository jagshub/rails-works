# frozen_string_literal: true

class SpamChecks::CheckWorker < ApplicationJob
  include ActiveJobHandlePostgresErrors
  include ActiveJobHandleDeserializationError

  def perform(action, request_info = nil)
    activity = ::SpamChecks::Activity.build(action, request_info)

    return if activity.skip_spam_check?
    return activity.mark_as_spam if actor_spammer?(activity.actor)

    SpamChecks::Rulesets.get_for_activity(activity.record).each do |ruleset|
      action_log = Spam::ActionLog.new(
        subject: activity.record,
        user: activity.actor,
        ruleset: ruleset,
      )

      activity.action_log = action_log

      check_results = ruleset.rules.map do |rule|
        result = SpamChecks::Filter.result(activity, rule)

        action_log.rule_logs.new(
          rule: rule,
          ruleset: ruleset,
          custom_value: rule.value,
          spam: result.spam?,
          checked_data: result.checked_data,
          filter_value: result.filter_value,
        )

        result.spam?
      end

      spam = check_results.all?

      # Note(Rahul): We take action when activity is spam
      #              And only after action we should save log below
      #              so that during error we don't create dup log
      if spam
        action_on_activity(activity, ruleset.action_on_activity)
        action_on_user(activity, ruleset.action_on_actor)
      end

      save_action_log action_log, spam

      # Note(Rahul): When we find a activity to be spam we can skip other rulesets
      break if spam
    end
  end

  private

  def actor_spammer?(actor)
    actor.spammer? || actor.potential_spammer?
  end

  def action_on_activity(activity, action_to_take)
    return if activity.record.is_a? User

    if action_to_take == 'mark_activity_spam'
      activity.mark_as_spam
    elsif action_to_take == 'report_activity'
      ::SpamChecks::Reports.add_new action_log: activity.action_log, to_check: :activity
    end
  end

  def action_on_user(activity, action_to_take)
    log = activity.action_log

    if action_to_take == 'mark_actor_spam'
      ::SpamChecks::Activity.mark_as_spam(log.user)
    elsif action_to_take == 'report_actor'
      ::SpamChecks::Reports.add_new action_log: log, to_check: :user
    end
  end

  def save_action_log(log, spam)
    ruleset = log.ruleset

    return if !spam && ruleset.ignore_not_spam_log

    log.action_taken_on_activity = spam ? ruleset.action_on_activity.to_s : nil
    log.action_taken_on_actor = spam ? ruleset.action_on_actor.to_s : nil
    log.spam = spam

    log.save!
  end
end
