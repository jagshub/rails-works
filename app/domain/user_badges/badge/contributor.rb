# frozen_string_literal: true

module UserBadges::Badge::Contributor
  extend UserBadges::Badge::Base
  extend self

  DEFAULT_STATUS = :in_progress
  MIN_VOTE_COUNT = 5
  MIN_COMMENT_COUNT = 5
  REQUIRED_KEYS = {
    identifier: ->(val) { val == UserBadges::AWARDS.index(self) },
    for_comment_id: ->(val) { val.present? },
  }.freeze

  def progress_requirement
    MIN_COMMENT_COUNT
  end

  def progress(data:)
    Comment.where(id: data['tracked_comment_ids'])
           .where('votes_count >= ?', MIN_VOTE_COUNT)
           .count
  end

  def validate?(data:, **_args)
    required_keys?(data) &&
      valid_key_values?(data)
  end

  def update_or_create(user:, data:)
    existing_badge = existing_badge_for_user(user, UserBadges::AWARDS.index(self))
    return if existing_badge.present? && !existing_badge&.in_progress?

    if existing_badge
      tracked_comment_ids = (existing_badge.data['tracked_comment_ids'] + [data[:for_comment_id]]).uniq
      existing_badge.update!(data: {
                               identifier: UserBadges::AWARDS.index(self),
                               status: meets_threshold?(tracked_comment_ids) ? :awarded_to_user_and_visible : :in_progress,
                               tracked_comment_ids: tracked_comment_ids,
                             })
    else
      Badges::UserAwardBadge.create!(
        subject: user,
        data: {
          identifier: UserBadges::AWARDS.index(self),
          status: :in_progress,
          tracked_comment_ids: [data[:for_comment_id]],
        },
      )
    end
  end

  private

  def meets_threshold?(comment_ids)
    Comment.where(id: comment_ids)
           .where('votes_count >= ?', MIN_VOTE_COUNT)
           .count >= MIN_COMMENT_COUNT
  end
end
