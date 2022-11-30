# frozen_string_literal: true

module Posts::Statistics
  extend self
  def generate_stats_for_launch_day_chart(post)
    Rails.cache.fetch(cache_key(post), expires_in: expiration(post)) do
      table = Vote.arel_table
      votes =
        post
        .votes
        .visible
        .group(group_by(post))
        .order('2')

      votes = if post.scheduled_at?
                votes.where(table[:created_at].gteq(post.scheduled_at))
              else
                votes.where(table[:created_at].gteq(post.created_at))
              end

      votes.count.map do |(date, count)|
        # NOTE(DZ): Ruby uses seconds since epoch, JS uses milliseconds
        {
          timestamp: date.to_time.to_i.in_milliseconds,
          value: count,
        }
      end
    end
  end

  private

  def cache_key(post)
    "post_upvote_time_series/#{ post.id }"
  end

  HOURLY_BREAKPOINT = 1.week

  def expiration(post)
    time = post.scheduled_at || post.created_at
    if time <= HOURLY_BREAKPOINT.ago
      1.day
    else
      1.hour
    end
  end

  def group_by(post)
    time = post.scheduled_at || post.created_at
    if time <= HOURLY_BREAKPOINT.ago
      "DATE_TRUNC('day', created_at)"
    else
      "DATE_TRUNC('hour', created_at)"
    end
  end
end
