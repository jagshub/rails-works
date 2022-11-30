# frozen_string_literal: true

module Feed
  extend self

  def posts(days_ago:)
    Feed::Posts.call(days_ago: days_ago)
  end

  def posts_count(days_ago:)
    Feed::Posts.count(days_ago: days_ago)
  end

  def posts_with_rank_count(rank_floor, days_ago:)
    Feed::Posts.with_rank_count(rank_floor, days_ago: days_ago)
  end
end
