# frozen_string_literal: true

# Note (TC): This badge is created/updated for the user who replied
# to a comment that was created by a user whos account age was < 7days
# at the time of reply.
class UserBadges::Workers::BuddySystemWorker < ApplicationJob
  include ActiveJobHandleDeserializationError

  BADGE_IDENTIFIER = 'buddy_system'
  MIN_USER_AGE = 7.days.freeze

  def perform(event)
    comment = event[:comment]
    return unless comment.parent_comment_id? &&
                  comment.parent.user.created_at > MIN_USER_AGE.ago &&
                  !comment.parent.user.blocked? &&
                  !comment.parent.trashed? &&
                  !comment.trashed? &&
                  !comment.user.blocked?

    return if comment.parent.user_id == comment.user_id
    return unless UserBadges.badge_active?(identifier: BADGE_IDENTIFIER)

    user = comment.user
    award = UserBadges.award_for(identifier: BADGE_IDENTIFIER)
    badge_data = { identifier: BADGE_IDENTIFIER, for_user_id: comment.parent.user_id, status: award::DEFAULT_STATUS }
    existing_badge = user.badges.with_data(identifier: BADGE_IDENTIFIER).first

    if existing_badge.nil?
      return unless award.validate?(data: badge_data, user: user)
    end

    award.update_or_create(data: badge_data, user: user)
  end
end
