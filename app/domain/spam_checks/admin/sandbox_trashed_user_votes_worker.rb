# frozen_string_literal: true

class SpamChecks::Admin::SandboxTrashedUserVotesWorker < ApplicationJob
  def perform(trashed_user)
    scope = if trashed_user.spammer?
              trashed_user.post_votes
            else
              trashed_user.post_votes.where(credible: false)
            end

    scope.update_all sandboxed: true, credible: false
  end
end
