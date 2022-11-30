# frozen_string_literal: true

# Note(Rahul): This is for manually marked spammers by admin

class SpamChecks::Admin::UserManualMarkAsSpammerWorker < ApplicationJob
  include ActiveJobHandlePostgresErrors
  include ActiveJobHandleDeserializationError

  def perform(user, handled_by, activity, reason)
    ActiveRecord::Base.transaction do
      ::SpamChecks::Activity.mark_as_spam user

      Spam::ManualLog.create!(
        action: 'mark_as_spammer',
        activity: activity,
        user: user,
        handled_by: handled_by,
        reason: reason,
      )
    end
  end
end
