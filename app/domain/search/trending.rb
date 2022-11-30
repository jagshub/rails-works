# frozen_string_literal: true

module Search::Trending
  extend self

  REDIS_KEY = 'search:trending:queries'

  def queries(limit: 5)
    JSON.parse(RedisConnect.current.get(REDIS_KEY) || '[]').first(limit)
  end

  # NOTE(DZ): Calculate queries based on naive 24 hour window by count
  def calculate_queries(limit: 10)
    queries = Search::UserSearch
      .after(24.hours.ago)
      .where('length(normalized_query) >= 3')
      .group(:normalized_query)
      .order(count: :desc)
      .limit(limit)
      .count
      .keys
      .map(&:titlecase)

    RedisConnect.current.set(REDIS_KEY, queries)
  end
end
