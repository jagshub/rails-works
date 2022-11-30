# frozen_string_literal: true

module TrendingPosts
  extend self

  TODAY = 'TODAY'
  THIS_WEEK = 'THIS_WEEK'
  LAST_WEEK = 'LAST_WEEK'
  VARIANTS = {
    TODAY => TrendingPosts::TodayVariant,
    THIS_WEEK => TrendingPosts::ThisWeekVariant,
    LAST_WEEK => TrendingPosts::LastWeekVariant,
  }.freeze

  def data_for(preferred_variant:, user:, limit: 4, exclude_product_ids: nil)
    TrendingPosts::Variant.new(preferred_variant, user, exclude_product_ids, limit)
  end
end
