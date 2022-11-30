# frozen_string_literal: true

# Note (TC): This worker will only create or update the badges `tracked_post_ids`
# data attribute for a user award badge. This visibility evaluation is handled via
# cron job UserBadges.gemologist_progress_worker
class UserBadges::Workers::GemologistWorker < ApplicationJob
  include ActiveJobHandleDeserializationError

  BADGE_IDENTIFIER = 'gemologist'

  def perform(event)
    comment = event[:comment]
    return unless comment.subject_type == 'Post' &&
                  comment.subject.visible? &&
                  !comment.user.blocked? &&
                  !comment.trashed?
    return if comment.subject.user_id == comment.user_id || comment.subject.maker_ids.include?(comment.user_id)
    return unless UserBadges.badge_active?(identifier: BADGE_IDENTIFIER)

    user = comment.user
    award = UserBadges.award_for(identifier: BADGE_IDENTIFIER)
    badge_data = { identifier: BADGE_IDENTIFIER, for_post_id: comment.subject_id, status: award::DEFAULT_STATUS }
    existing_badge = user.badges.with_data(identifier: BADGE_IDENTIFIER).first

    if existing_badge.nil?
      return unless award.validate?(data: badge_data, user: user)
    end

    award.update_or_create(data: badge_data, user: user)
  end
end
