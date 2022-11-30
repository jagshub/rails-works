# frozen_string_literal: true

class API::V2Internal::Resolvers::PostsResolver < API::V2Internal::Resolvers::BaseSearchResolver
  scope { Post.featured }

  class SortType < Graph::Types::BaseEnum
    graphql_name 'PostsSort'

    value 'FEATURED_AT'
    value 'VOTES'
    value 'RANKING'
  end

  option :sort, type: SortType, default: 'RANKING'

  def apply_sort_with_votes(scope)
    scope.by_credible_votes
  end

  def apply_sort_with_featured_at(scope)
    scope.by_featured_at
  end

  def apply_sort_with_ranking(scope)
    scope
      .select("*, (#{ ::Posts::Ranking.algorithm_in_sql }) AS rank")
      .order(
        Arel.sql("DATE_TRUNC('day', featured_at::timestamptz at time zone 'america/los_angeles') DESC NULLS LAST"),
        rank: :desc,
      )
  end
end
