# frozen_string_literal: true

module UserBadges::Badge::BuddySystem
  extend UserBadges::Badge::Base
  extend self

  DEFAULT_STATUS = :in_progress
  MIN_REPLY_COUNT = 10
  REQUIRED_KEYS = {
    identifier: ->(val) { val == UserBadges::AWARDS.index(self) },
    for_user_id: ->(val) { val.present? },
  }.freeze

  def progress_requirement
    MIN_REPLY_COUNT
  end

  def progress(data:)
    data['for_user_ids'].count
  end

  def validate?(data:, **_args)
    required_keys?(data) &&
      valid_key_values?(data)
  end

  def update_or_create(user:, data:)
    existing_badge = existing_badge_for_user(user, UserBadges::AWARDS.index(self))
    return if existing_badge.present? && !existing_badge&.in_progress?

    if existing_badge
      replied_user_ids = (existing_badge.data['for_user_ids'] + [data[:for_user_id]]).uniq
      existing_badge.update!(data: {
                               identifier: UserBadges::AWARDS.index(self),
                               status: replied_user_ids.count >= MIN_REPLY_COUNT ? :awarded_to_user_and_visible : :in_progress,
                               for_user_ids: replied_user_ids,
                             })
    else
      Badges::UserAwardBadge.create!(
        subject: user,
        data: {
          identifier: 'buddy_system',
          status: :in_progress,
          for_user_ids: [data[:for_user_id]],
        },
      )
    end
  end
end
