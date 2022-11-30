# frozen_string_literal: true

module UserBadges::Badge::Gemologist
  extend UserBadges::Badge::Base
  extend self

  DEFAULT_STATUS = :in_progress
  MAX_VOTE_THRESHOLD = 5
  AWARD_VOTE_THRESHOLD = 20
  POST_EXPIRY_LIMIT = 3.days
  REQUIRED_KEYS = {
    identifier: ->(val) { val == UserBadges::AWARDS.index(self) },
    for_post_id: ->(val) { val.present? },
  }.freeze

  def stackable?
    true
  end

  def validate?(data:, user:)
    required_keys?(data) &&
      valid_key_values?(data) &&
      post_is_valid?(data) &&
      post_is_unique_to_user?(data, user)
  end

  def update_or_create(data:, user:)
    existing_badge = existing_badge_for_user(user, UserBadges::AWARDS.index(self))
    return if existing_badge.present? && !existing_badge&.in_progress?

    if existing_badge
      updated_tracked_posts = ((existing_badge.data['tracked_post_ids'] || []) + [data[:for_post_id]]).uniq
      existing_badge.update!(data: {
                               status: :in_progress,
                               identifier: UserBadges::AWARDS.index(self),
                               tracked_post_ids: updated_tracked_posts,
                             })
    else
      Badges::UserAwardBadge.create!(
        subject: user,
        data: {
          status: :in_progress,
          identifier: UserBadges::AWARDS.index(self),
          tracked_post_ids: [data[:for_post_id]],
        },
      )
    end
  end

  # Note(TC): Method for the background worker to call
  # that can update the progress of the badge that is not visible
  # this method will update the progress of posts to watch as well as
  # cleanup invalid posts (posts that were trashed or are outside expiry) from being tracked
  def update_progress(badge:)
    has_post_above_threshold = false
    valid_post_ids = []

    Post.where(id: badge.data['tracked_post_ids']).each do |post|
      next unless post.visible? && post.scheduled_at > POST_EXPIRY_LIMIT.ago

      valid_post_ids.push(post.id)

      has_post_above_threshold ||= post.votes_count >= AWARD_VOTE_THRESHOLD
    end

    # Note(TC): If we filtered out all the posts we were watching
    # then we can just wait for them to re-create the badge and delete
    # this one to stop watching it.
    if valid_post_ids.empty?
      badge.destroy!
      return
    end

    badge.update!(data: {
                    status: has_post_above_threshold ? :awarded_to_user_and_visible : :in_progress,
                    identifier: UserBadges::AWARDS.index(self),
                    tracked_post_ids: valid_post_ids,
                  })
  end

  private

  def post_is_valid?(data)
    post = Post.find_by_id(data[:for_post_id])
    return false if post.nil?

    post.visible? && post.votes_count <= MAX_VOTE_THRESHOLD
  end

  def post_is_unique_to_user?(data, user)
    existing_badge = existing_badge_for_user(user, UserBadges::AWARDS.index(self))
    return true if existing_badge.nil?

    !existing_badge.data['tracked_post_ids'].include?(data[:for_post_id])
  end
end
