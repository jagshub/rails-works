# frozen_string_literal: true

class Graph::Resolvers::Search::DevProductResolver < Graph::Resolvers::Base
  type Graph::Types::ProductType.connection_type, null: false

  argument :query, String, required: true
  argument :rank_by, String, required: false
  argument :weight, Int, required: false
  argument :decay, Int, required: false
  argument :boosts, Graph::Types::JsonType, required: false

  def resolve(query:, rank_by: 'total', weight: 50, decay: 50, boosts: {})
    return [] unless current_user&.admin?

    Search.dev_query_product(
      query,
      rank_by: rank_by,
      weight: weight,
      decay: decay,
      boosts: boosts,
    )
  end
end
