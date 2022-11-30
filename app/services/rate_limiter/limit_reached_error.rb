# frozen_string_literal: true

module RateLimiter
  class LimitReachedError < StandardError
    attr_reader :rate_limiter

    def initialize(rate_limiter)
      @rate_limiter = rate_limiter
    end
  end
end
