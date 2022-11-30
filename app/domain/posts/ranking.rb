# frozen_string_literal: true

module Posts::Ranking
  extend self

  def apply(scope, top: false)
    scope.order(Arel.sql("#{ algorithm_in_sql(top: top) } DESC")).order('scheduled_at DESC')
  end

  def algorithm_in_sql(top: false)
    settings = Rails.configuration.settings

    # NOTE(naman): do not consider featured_at to make fresh products rank up for top products feed
    return "( ( credible_votes_count + #{ settings.rank_upvote_addition.to_f } ) * score_multiplier )" if top

    # NOTE(DZ): Someone should try and explain this code
    <<-SQL
      (
        (
            ((credible_votes_count) + #{ settings.rank_upvote_addition.to_f }) /
            (abs(
                extract(
                    epoch from (now() - featured_at) + '#{ settings.rank_time_addition.to_f / 60 } hours'::interval
                    ) / 60
                ) ^ #{ settings.rank_time_multiplier.to_f }
            )
        ) * score_multiplier
    )
    SQL
  end

  def for_day(day, scope: Post)
    scope = scope.featured
    scope = scope.for_featured_date(day.to_date)
    scope = apply(scope)
    scope
  end
end
