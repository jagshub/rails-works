# frozen_string_literal: true

class Posts::RankingUpdater
  attr_reader :field, :start_time, :end_time, :by_credible_votes, :ranked_ids

  def self.nullify_unfeatured
    scope = Post.where(featured_at: nil)

    scope.where.not(daily_rank: nil).update_all(daily_rank: nil)
    scope.where.not(weekly_rank: nil).update_all(weekly_rank: nil)
    scope.where.not(monthly_rank: nil).update_all(monthly_rank: nil)
  end

  def self.for_day(time, **options)
    start_time = time.beginning_of_day
    end_time = time.end_of_day

    new(
      field: :daily_rank,
      start_time: start_time,
      end_time: end_time,
      by_credible_votes: false,
      **options,
    )
  end

  def self.for_week(time, **options)
    start_time = time.beginning_of_week
    end_time = time.end_of_week

    new(
      field: :weekly_rank,
      start_time: start_time,
      end_time: end_time,
      by_credible_votes: true,
      **options,
    )
  end

  def self.for_month(time, **options)
    start_time = time.beginning_of_month
    end_time = time.end_of_month

    new(
      field: :monthly_rank,
      start_time: start_time,
      end_time: end_time,
      by_credible_votes: true,
      **options,
    )
  end

  def initialize(field:, start_time:, end_time:, by_credible_votes: false, ranked_ids: [])
    @field = field
    @start_time = start_time
    @end_time = end_time

    # Note(AR): Monthly and weekly rankings do not use a time-adjusted
    # algorithm, they just order by credible votes:
    @by_credible_votes = by_credible_votes

    # Note(AR): If we have posts with awarded badges, we provide their ids in
    # order to pin their rankings:
    @ranked_ids = ranked_ids
  end

  def call
    scope = Post.featured
    scope = scope.where(featured_at: start_time..end_time)
    scope = scope.joins(:votes).where(votes: { credible: true, sandboxed: false })
    scope = scope.where('votes.created_at <= ?', end_time)
    scope = scope.group('posts.id')

    scope =
      if by_credible_votes
        scope.order(Arel.sql('COUNT(votes.id) * posts.score_multiplier DESC'))
      else
        scope.order(ranking_algorithm_sql)
      end

    Post.transaction do
      offset = 0

      if ranked_ids.present?
        # Note(AR): Some of these might be unfeatured, but we have to assign
        # them anyway, to maintain consistency badge positions.
        Post.find(ranked_ids).each.with_index do |post, index|
          rank = index + 1
          post.update!(field => rank) if post[field] != rank
        end

        scope = scope.where.not(id: ranked_ids)
        offset = ranked_ids.length
      end

      scope.each.with_index do |post, index|
        rank = offset + index + 1

        # NOTE(rstankov): Excluded products have a rank, but it is hidden in UI and they don't get badges
        #   We duplicate the ranking so it orders correctly in listings
        #   Example ranking with excluded: 1, 2, [2], 3, 4, ...
        offset -= 1 if post.exclude_from_ranking?

        post.update!(field => rank) if post[field] != rank
      end
    end
  end

  private

  # Note(AR): Copied from `Posts::Ranking.algorithm_in_sql`, but:
  #
  # - Uses `COUNT(votes)` instead of cached `credible_votes_count`
  # - Uses the object's `end_time` rather than the current time
  #
  # The logic behind it is to order by "votes" divided by the time the post had
  # until the end of the time period, with some coefficients to adjust things.
  # So, the rank is essentially "votes per time unit". An early post is going
  # to have more time to accumulate votes, so we divide it by a larger number.
  #
  def ranking_algorithm_sql
    settings = Rails.configuration.settings
    end_time_string = end_time.to_s(:db)

    Arel.sql(<<~SQL)
      (
        (
          (COUNT(votes) + #{ settings.rank_upvote_addition.to_f }) /
          (abs(
            extract(
              epoch from ('#{ end_time_string }'::timestamp - featured_at) + '#{ settings.rank_time_addition.to_f / 60 } hours'::interval
            ) / 60
          ) ^ #{ settings.rank_time_multiplier.to_f })
        ) * score_multiplier
      ) DESC
    SQL
  end
end
