# frozen_string_literal: true

module Newsletter::Counters
  extend self

  KEYS = %w(job_enqueue fan_out start missing sending send skip).freeze

  def start_fan_out(newsletter)
    RedisConnect.current.set("newsletter:#{ newsletter.id }:start_time", Time.zone.now)
  end

  def stop_fan_out(newsletter)
    RedisConnect.current.set("newsletter:#{ newsletter.id }:start_end", Time.zone.now)
  end

  def increment(newsletter, key)
    return unless setting_enabled?

    RedisConnect.current.incr("newsletter:#{ newsletter.id }:#{ key }")
  end

  def count(newsletter, key)
    raise 'Unknown key' unless KEYS.include?(key)

    RedisConnect.current.get("newsletter:#{ newsletter.id }:#{ key }")
  end

  def increment_by(newsletter, count, key)
    return unless setting_enabled?

    RedisConnect.current.incrby("newsletter:#{ newsletter.id }:#{ key }", count)
  end

  def fetch_start_fan_out(newsletter)
    RedisConnect.current.get("newsletter:#{ newsletter.id }:start_time")
  end

  def fetch_stop_fan_out(newsletter)
    RedisConnect.current.get("newsletter:#{ newsletter.id }:end_time")
  end

  private

  def setting_enabled?
    Setting.enabled?('newsletter_track')
  end
end
