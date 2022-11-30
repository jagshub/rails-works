# frozen_string_literal: true

module TrendingPosts::TodayVariant
  extend self

  VISIBILITY_THRESHOLD = 6.hours.freeze

  def name
    TrendingPosts::TODAY
  end

  def featured_at_range
    now = Time.zone.now
    start_at = now.beginning_of_day
    end_at = now
    start_at..end_at
  end

  def cache_key
    "top_posts_for_#{ name }"
  end

  def cache_expiry
    1.hour
  end

  def pick_or_fallback
    if Time.zone.now - Time.zone.now.beginning_of_day >= VISIBILITY_THRESHOLD
      self
    else
      TrendingPosts::ThisWeekVariant.pick_or_fallback
    end
  end
end
