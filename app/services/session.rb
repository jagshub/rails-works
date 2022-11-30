# frozen_string_literal: true

class Mobile::Session
  attr_reader :session_key

  # Note(jag): set to 1 week
  EXPIRE_IN_SECONDS = 1.week.to_i

  REDIS = RedisConnect.to(Config.secret(:session_redis_url))

  def initialize(session_key: nil)
    @session_key = session_key
  end

  def save(force = false)
    return true if @values.nil? && !force

    REDIS.set(session_key, values.to_json, ex: EXPIRE_IN_SECONDS)
    true
  end

  delegate :[], :[]=, to: :values

  private

  def values
    @values ||= load_values
  end

  def load_values
    data = REDIS.get(session_key)
    return {} if data.nil?

    JSON.parse(data, symbolize_names: true)
  end
end
