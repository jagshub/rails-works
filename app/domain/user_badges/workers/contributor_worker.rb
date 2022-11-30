# frozen_string_literal: true

# Note (TC): This badge is awarded to users who author 5 comments that
# accumulate more than 5 upvotes. These comments must be comments on
# discussion::threads in order to count towards this badge.
class UserBadges::Workers::ContributorWorker < ApplicationJob
  include ActiveJobHandleDeserializationError

  BADGE_IDENTIFIER = 'contributor'

  def perform(vote)
    return unless vote.subject_type == 'Comment' &&
                  vote.subject.subject_type == 'Discussion::Thread' &&
                  vote.subject.subject.approved? &&
                  !vote.subject.subject.trashed? &&
                  vote.credible?
    return if vote.subject.user_id == vote.user_id
    return unless UserBadges.badge_active?(identifier: BADGE_IDENTIFIER)

    user = vote.subject.user
    award = UserBadges.award_for(identifier: BADGE_IDENTIFIER)
    badge_data = { identifier: BADGE_IDENTIFIER, for_comment_id: vote.subject_id, status: award::DEFAULT_STATUS }
    existing_badge = user.badges.with_data(identifier: BADGE_IDENTIFIER).first

    if existing_badge.nil?
      return unless award.validate?(data: badge_data, user: user)
    end

    award.update_or_create(data: badge_data, user: user)
  end
end
