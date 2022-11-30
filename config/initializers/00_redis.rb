# frozen_string_literal: true

require 'redis_connect'

# Note(AR): Some of the code in gems uses the REDIS_URL variable directly, so
# it needs to be set:
ENV['REDIS_URL'] = Config.secret(:redis_url)

RedisConnect.current = RedisConnect.to(Config.secret(:redis_url)) unless Rails.env.test?
