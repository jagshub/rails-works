# frozen_string_literal: true

module Spam::MarkVoteAsSpam
  extend self

  def call(vote:, current_user:, remarks:)
    Spam::Log.transaction do
      vote.update! credible: false, sandboxed: true
      vote.subject.refresh_all_vote_counts

      log_entry = Spam.mark_entity(
        level: :inappropriate,
        kind: :manual,
        entity: vote,
        current_user: current_user,
        user: vote.user,
        remarks: remarks,
      )

      job_payload = log_entry.job_payload

      Spam::SpamUserWorker.perform_later(
        job_payload,
        actions: %w(update_role mark_votes),
      )

      vote
    end
  end
end
