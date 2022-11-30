# frozen_string_literal: true

module Voting
  extend self

  NOTIFY_ELIGIBLE = ['Post', 'Discussion::Thread', 'Comment'].freeze

  def create(subject:, user:, source:, request_info: nil, source_component: nil)
    vote = Voting::Create.call(
      subject: subject,
      user: user,
      request_info: request_info,
      source: source,
      source_component: source_component,
    )

    notify_eligible_objects(vote)

    vote
  end

  def destroy(subject:, user:)
    Voting::Destroy.call(subject: subject, user: user)
  end

  def voted?(subject:, user:)
    user.votes.where(subject: subject).exists?
  end

  def votes(subject:, as_seen_by: nil)
    Voting::Repository.votes(subject: subject, as_seen_by: as_seen_by)
  end

  def votes_by(user, type:, as_seen_by: nil)
    Voting::Repository.votes_by(user, type: type, as_seen_by: as_seen_by)
  end

  def mark_as_spam(vote, more_information: nil, sandboxed: true, remarks: nil)
    Spam::Log.transaction do
      vote.reload.update!(sandboxed: sandboxed, credible: false)
      Spam.log_entity(
        level: :questionable,
        kind: :automatic,
        entity: vote,
        user: vote.user,
        remarks: remarks || "Vote detected as spam, marked non-credible and #{ sandboxed ? '' : 'not ' }sandboxed. See checks results for more info.",
        action: :mark_as_non_credible,
        more_information: more_information,
      )
    end
    vote.subject.refresh_all_vote_counts
    vote
  end

  private

  def notify_eligible_objects(vote)
    if vote.present? && NOTIFY_ELIGIBLE.include?(vote&.subject_type)
      Notifications.notify_about(kind: 'vote', object: vote) if Features.enabled?('ph_upvote_notification', vote.subject&.user)
    end
  end
end
