# frozen_string_literal: true

class Products::NewLaunchUpdateWithThrottle
  class << self
    attr_accessor :redis_connection

    def redis_connection
      @redis_connection ||= ConnectionPool.new(size: 5, timeout: 5) do
        if Rails.env.production?
          RedisConnect.to(ENV.fetch('RAILS_CACHE_REDIS_URL'))
        else
          Redis.new
        end
      end
    end

    def redis(&block)
      redis_connection.with(&block)
    end

    def run_today?
      redis do |r|
        runs = r.get(redis_daily_run_key).to_i
        return true if runs == 1

        r.set(redis_daily_run_key, 1)
        return false
      end
    end

    def redis_daily_run_key
      "products:new_launch_update:daily_run:#{ Time.zone.today }"
    end
  end

  # NOTE(DZ): This is to be updated based on performance
  MAX_EMAILS_PER_WEEK = 5
  attr_reader :date, :post

  def initialize(post)
    @date = Time.zone.today
    @post = post
  end

  def send_email(user)
    return unless can_send_email?(user)

    ProductMailer.new_launch_update(user, post).deliver_later
    self.class.redis { |r| r.incr(redis_weekly_run_key(user)) }
  end

  def can_send_email?(user)
    self.class.redis { |r| r.get(redis_weekly_run_key(user)).to_i < MAX_EMAILS_PER_WEEK }
  end

  def redis_weekly_run_key(user)
    # NOTE(DZ): Tuesday is the most post frequency. Use that as day of refresh.
    week = date.beginning_of_week(:tuesday).to_date
    "products:new_launch_update:#{ week }:#{ user.id }"
  end
end
