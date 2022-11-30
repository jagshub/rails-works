# frozen_string_literal: true

module Feed::Posts
  extend self

  def call(days_ago:)
    popular_scope(days_ago: days_ago).select("*, (#{ ::Posts::Ranking.algorithm_in_sql }) as rank").order('rank DESC')
  end

  def count(days_ago:)
    popular_scope(days_ago: days_ago).count
  end

  def with_rank_count(rank_floor, days_ago:)
    Post.select('*').from(call(days_ago: days_ago)).where('rank > ?', rank_floor).count
  end

  private

  def popular_scope(days_ago:)
    Post.featured.for_featured_date(days_ago.to_i.days.ago.to_date)
  end
end
