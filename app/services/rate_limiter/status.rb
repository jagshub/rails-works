# frozen_string_literal: true

module RateLimiter
  class Status
    attr_accessor :remaining
    attr_accessor :last_reset_at

    def initialize(remaining: nil, last_reset_at: nil)
      @remaining = remaining
      @last_reset_at = last_reset_at
    end

    def seconds_until_reset
      LIMIT_INTERVAL.since(@last_reset_at).to_i - Time.current.to_i
    end
  end
end
