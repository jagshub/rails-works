# frozen_string_literal: true

module TrendingPosts::ThisWeekVariant
  extend self

  VISIBILITY_THRESHOLD = 2.days.freeze

  def name
    TrendingPosts::THIS_WEEK
  end

  def featured_at_range
    now = Time.zone.now
    start_at = now.beginning_of_week
    end_at = now
    start_at..end_at
  end

  def cache_key
    "top_posts_for_#{ name }"
  end

  def cache_expiry
    6.hours
  end

  def pick_or_fallback
    if Time.zone.now - Time.zone.now.beginning_of_week >= VISIBILITY_THRESHOLD
      self
    else
      TrendingPosts::LastWeekVariant.pick_or_fallback
    end
  end
end
