# frozen_string_literal: true

require 'redis/namespace'

class Spam::TwitterSuspensionCheckWorker < ApplicationJob
  LIMIT_RESET_AT = 'limit_reset_at'
  NAMESPACE = 'twitter-suspension-check'

  def perform(users:)
    redis = Redis::Namespace.new NAMESPACE, redis: RedisConnect.current

    limit_reset_at = redis.get LIMIT_RESET_AT
    return retry_job wait_until: limit_reset_at if limit_reset_at.present? && Time.zone.now < limit_reset_at

    begin
      active_users = users.select { |user| user.role = 'user' }
      Spam::Users::Checks::TwitterSuspension.run users: active_users
    rescue Twitter::Error::TooManyRequests => e
      retry_after = (e.rate_limit.to_h[:reset_in] + 1).seconds.from_now

      retry_job wait_until: retry_after
      redis.set LIMIT_RESET_AT, retry_after
    end
  end
end
