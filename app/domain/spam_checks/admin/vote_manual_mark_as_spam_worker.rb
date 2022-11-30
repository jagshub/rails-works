# frozen_string_literal: true

class SpamChecks::Admin::VoteManualMarkAsSpamWorker < ApplicationJob
  include ActiveJobHandlePostgresErrors
  include ActiveJobHandleDeserializationError

  def perform(vote, handled_by, reason)
    ActiveRecord::Base.transaction do
      ::SpamChecks::Activity.mark_as_spam(vote)

      vote.user.potential_spammer! unless vote.user.blocked?

      Spam::ManualLog.create!(
        action: 'mark_vote_as_spam',
        activity: vote,
        user: vote.user,
        handled_by: handled_by,
        reason: reason,
      )
    end
  end
end
