# frozen_string_literal: true

class SpamChecks::Admin::RevertManualLogWorker < ApplicationJob
  include ActiveJobHandlePostgresErrors
  include ActiveJobHandleDeserializationError

  def perform(log, reverted_by, reason)
    return unless log.can_revert_action?

    ActiveRecord::Base.transaction do
      if log.mark_as_bad_actor?
        revert_from_bad_actor log
      elsif log.mark_as_spammer?
        ::SpamChecks::Activity.revert_action_taken log.user
      end

      log.update! reverted_by: reverted_by, revert_reason: reason
    end
  end

  private

  def revert_from_bad_actor(log)
    log.user.user!

    activity = log.activity
    return if activity.blank?

    if activity.is_a? Post
      log.activity.restore
    else
      activity.unhide!
    end
  end
end
