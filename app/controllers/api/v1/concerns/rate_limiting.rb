# frozen_string_literal: true

module RateLimiting
  extend ActiveSupport::Concern

  attr_accessor :rate_limiter

  included do
    before_action :rate_limit_check
    after_action :rate_limit_update

    private

    def rate_limit_points_in_request
      raise NotImplementedError
    end

    def rate_limit_points_quota_per_hour
      raise NotImplementedError
    end

    def rate_limit_identifier_for_limiter
      # NOTE(Dhruv): This ensures we can have seperate rate limiters for
      # single app depending on whether the request endpoint is GraphQL or REST
      # For e.g an app would have points based rate limiting when hitting
      # `/v2/api/graphql` endpoint whereas same app would have request based
      # rate limiting when requesting access tokens via `v2/oauth/token`
      # Defaulting to `nil` to ensure existing RateLimiter keys for v1 don't get
      # purged when this is deployed.
      nil
    end

    def rate_limit_check
      return if doorkeeper_token.blank?

      app = doorkeeper_token.application
      max_points_per_hour = rate_limit_points_quota_per_hour(app)
      return if max_points_per_hour == 0

      HandleRedisErrors.call(fallback: ->(e) { ErrorReporting.report_error(e) }) do
        @rate_limiter = RateLimiter::API.for(app, max_points_per_hour, rate_limit_identifier_for_limiter)

        response.headers['X-Rate-Limit-Limit']     = rate_limiter.limit
        response.headers['X-Rate-Limit-Remaining'] = rate_limiter.remaining
        response.headers['X-Rate-Limit-Reset']     = rate_limiter.seconds_until_reset

        rate_limit_reached(app, rate_limiter) unless rate_limiter.request_allowed?
      end
    end

    def rate_limit_update
      return unless rate_limiter

      HandleRedisErrors.call(fallback: ->(e) { ErrorReporting.report_error(e) }) do
        rate_limiter.decrement(rate_limit_points_in_request) if rate_limit_points_in_request.present?
      end
    end

    def rate_limit_reached(app, rate_limiter)
      raise RateLimiter::LimitReachedError, rate_limiter if Rails.configuration.settings.enforce_api_rate_limit?

      Rails.logger.info format('Application #%d hit rate limit, %ds until rate limit reset', app.id, rate_limiter.seconds_until_reset)
    end
  end
end
