# frozen_string_literal: true

module ClearbitProfiles::EnrichQueue
  extend self

  class << self
    # NOTE(DZ): :redis is set by clearbit_sync.rb
    # config/initializers/clearbit_sync.rb
    attr_accessor :redis_connection
  end

  def redis(&block)
    redis_connection.with(&block)
  end

  def push(user)
    redis { |r| r.rpush(redis_key, user.id) }
  end

  def push_id(user_id)
    redis { |r| r.rpush(redis_key, user_id) }
  end

  def reserve(limit: 1000)
    # NOTE(DZ): rpop is supported on redis 6.2 and greater, currently we're on
    # 6.2.6. Do note this will not work if we downgrade
    redis { |r| r.call('rpop', redis_key, limit) }
  end

  def clear
    redis { |r| r.del(redis_key) }
  end

  def length
    redis { |r| r.llen(redis_key) }
  end

  private

  def redis_key
    'clearbit:enrich_queue:users'
  end
end
