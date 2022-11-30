# frozen_string_literal: true

module Notifications::TopPostCompetitionPush
  extend self

  VOTE_MAX_GAP = 55
  NOTIFIER_KIND = :top_post_competition
  COOLDOWN_IN_DAYS = 7

  # Note (TC): This notifier alerts users when the top two posts near the end of the day are within
  # a close call of each other. It should be set on a cooldown so it is not sent out too often.
  def call
    return if on_cooldown?

    top_posts = ::Post.today.visible.by_credible_votes.limit(2)
    return if top_posts.size < 2

    vote_difference = (top_posts.first.votes_count - top_posts.second.votes_count).abs
    return if vote_difference > VOTE_MAX_GAP

    top_post_ids = top_posts.map(&:id)
    User.credible.find_each do |user|
      # skip if user has voted on either post we are suggesting
      next if Vote.where(subject_id: top_post_ids, user_id: user.id).exists?

      notifier = Notifications::Notifiers.for(NOTIFIER_KIND)
      notifier.fan_out(top_posts.sample, kind: NOTIFIER_KIND.to_s, user: user)
    end
  end

  private

  def on_cooldown?
    last_notification = ::NotificationLog.where(kind: NOTIFIER_KIND.to_s).last
    return false if last_notification.nil?

    last_notification.created_at.to_date >= COOLDOWN_IN_DAYS.day.ago.to_date
  end
end
