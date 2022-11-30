# frozen_string_literal: true

module RedisConnect
  extend self

  def current
    @current ||= RedisConnect.to(Config.secret(:redis_url))
  end

  def current=(redis)
    @current = redis
  end

  def to(redis_url)
    if Rails.env.staging?
      # NOTE(rstankov): Demo ENV share the same Redis instance, so we need to namespace
      Redis::Namespace.new("demo#{ Config.staging_id }", redis: Redis.new(url: redis_url))
    else
      Redis.new(url: redis_url)
    end
  end
end
