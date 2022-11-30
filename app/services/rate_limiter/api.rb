# frozen_string_literal: true

module RateLimiter
  module API
    extend self

    def app_ids
      RedisConnect.current.keys("#{ NAMESPACE }*#{ Limiter::REMAINING_KEY }").map do |key|
        key.gsub(/[^\d]/, '').to_i
      end
    end

    def for(app, limit_per_hour, identifier_for_limiter = nil)
      RateLimiter.for(
        subject: [:api, app],
        limit_per_hour: limit_per_hour,
        identifier_for_limiter: identifier_for_limiter,
      )
    end
  end
end
