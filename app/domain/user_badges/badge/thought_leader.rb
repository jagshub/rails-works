# frozen_string_literal: true

module UserBadges::Badge::ThoughtLeader
  extend UserBadges::Badge::Base
  extend self

  DEFAULT_STATUS = :in_progress
  MIN_VOTE_COUNT = 10
  MIN_THREAD_COUNT = 5
  REQUIRED_KEYS = {
    identifier: ->(val) { val == UserBadges::AWARDS.index(self) },
    for_thread_id: ->(val) { val.present? },
  }.freeze

  def progress_requirement
    MIN_THREAD_COUNT
  end

  def progress(data:)
    Discussion::Thread
      .where(id: data['tracked_thread_ids'])
      .where('votes_count >= ?', MIN_VOTE_COUNT)
      .count
  end

  def validate?(data:, **_args)
    required_keys?(data) &&
      valid_key_values?(data)
  end

  def update_or_create(data:, user:)
    existing_badge = existing_badge_for_user(user, UserBadges::AWARDS.index(self))
    return if existing_badge.present? && !existing_badge&.in_progress?

    if existing_badge
      tracked_thread_ids = (existing_badge.data['tracked_thread_ids'] + [data[:for_thread_id]]).uniq
      existing_badge.update!(data: {
                               identifier: UserBadges::AWARDS.index(self),
                               status: meets_threshold?(tracked_thread_ids) ? :awarded_to_user_and_visible : :in_progress,
                               tracked_thread_ids: tracked_thread_ids,
                             })
    else
      Badges::UserAwardBadge.create!(
        subject: user,
        data: {
          identifier: UserBadges::AWARDS.index(self),
          status: :in_progress,
          tracked_thread_ids: [data[:for_thread_id]],
        },
      )
    end
  end

  private

  def meets_threshold?(thread_ids)
    threads_over_vote = Discussion::Thread.where(id: thread_ids).where('votes_count >= ?', MIN_VOTE_COUNT)

    threads_over_vote.count >= MIN_THREAD_COUNT
  end
end
