# frozen_string_literal: true

require 'redis/namespace'

module RateLimiter
  LIMIT_INTERVAL = 15.minutes
  NAMESPACE = :rate_limit

  extend self

  def for(subject: nil, limit_per_hour: nil, identifier_for_limiter: nil)
    limiter_key_params = [NAMESPACE, subject.to_param, identifier_for_limiter].compact.to_param
    redis = Redis::Namespace.new limiter_key_params, redis: RedisConnect.current
    Limiter.new(redis: redis, limit: limit_for_interval(limit_per_hour))
  end

  private

  def limit_for_interval(limit)
    (limit / resets_per_hour).ceil
  end

  def resets_per_hour
    (1.hour / LIMIT_INTERVAL).to_f
  end
end
