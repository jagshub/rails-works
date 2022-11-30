# frozen_string_literal: true

# Note(TC): User creates 10 threads that earn >= 5 upvotes.
# Earned once per-user.
class UserBadges::Workers::ThoughtLeaderWorker < ApplicationJob
  include ActiveJobHandleDeserializationError

  BADGE_IDENTIFIER = 'thought_leader'

  def perform(vote)
    return unless vote.subject_type == 'Discussion::Thread' &&
                  vote.subject.approved? &&
                  !vote.subject.trashed? &&
                  vote.credible?
    return if vote.subject.user_id == vote.user_id
    return unless UserBadges.badge_active?(identifier: BADGE_IDENTIFIER)

    user = vote.subject.user
    award = UserBadges.award_for(identifier: BADGE_IDENTIFIER)
    badge_data = { identifier: BADGE_IDENTIFIER, for_thread_id: vote.subject_id, status: award::DEFAULT_STATUS }
    existing_badge = user.badges.with_data(identifier: BADGE_IDENTIFIER).first

    if existing_badge.nil?
      return unless award.validate?(data: badge_data, user: user)
    end

    award.update_or_create(data: badge_data, user: user)
  end
end
