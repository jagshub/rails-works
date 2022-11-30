# frozen_string_literal: true

module TrendingPosts::LastWeekVariant
  extend self

  def name
    TrendingPosts::LAST_WEEK
  end

  def featured_at_range
    now = Time.zone.now
    start_at = (now.beginning_of_week - 1.week)
    end_at = start_at.end_of_week
    start_at..end_at
  end

  def cache_key
    "top_posts_for_#{ name }"
  end

  def cache_expiry
    1.day
  end

  def pick_or_fallback
    self
  end
end
