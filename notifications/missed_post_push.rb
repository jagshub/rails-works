# frozen_string_literal: true

module Notifications::MissedPostPush
  extend self

  LAST_ACTIVE_LIMIT = 5
  NOTIFIER_KIND = :missed_post

  # Note (TC): This notifier is so that we can find users who have not been recently active and give
  # them a topical post that they may want to click on as a notification, or just a random post they missed.
  def call
    User.where(last_active_at: LAST_ACTIVE_LIMIT.days.ago).credible.find_each do |user|
      followed_topics = user.followed_topics.pluck(:id)
      posts_missed = Feed::WhatYouMissed.call(since: LAST_ACTIVE_LIMIT.days.ago, user: user, topic_ids: followed_topics, limit: 10)

      notifier = Notifications::Notifiers.for(NOTIFIER_KIND)
      notifier.fan_out(posts_missed.sample, kind: NOTIFIER_KIND.to_s, user: user)
    end
  end
end
