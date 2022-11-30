# frozen_string_literal: true

module RateLimiter
  class Limiter
    LAST_RESET_AT_KEY = 'last_reset_at'
    REMAINING_KEY     = 'remaining'

    attr_reader :limit
    attr_reader :status

    delegate :remaining, :last_reset_at, :seconds_until_reset, to: :status

    def initialize(redis: nil, limit: nil)
      @redis = redis
      @limit = limit
      @status = load_status || reset
    end

    def request_allowed?
      @status.remaining > 0
    end

    def decrement(points)
      HandleRedisErrors.call do
        @status.remaining -= points
        @redis.set(REMAINING_KEY, @status.remaining)
      end
    end

    private

    def load_status
      last_reset_at, remaining = HandleRedisErrors.call(fallback: []) { @redis.mget(LAST_RESET_AT_KEY, REMAINING_KEY) }

      return if last_reset_at.nil? || last_reset_at.to_i < LIMIT_INTERVAL.ago.to_i

      Status.new(remaining: remaining.to_i, last_reset_at: Time.zone.at(last_reset_at.to_i))
    end

    def reset
      HandleRedisErrors.call do
        status = Status.new(remaining: @limit, last_reset_at: Time.current)

        @redis.set(REMAINING_KEY,     status.remaining)
        @redis.set(LAST_RESET_AT_KEY, status.last_reset_at.to_i)

        status
      end
    end
  end
end
