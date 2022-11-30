# frozen_string_literal: true

class Graph::Resolvers::RecommendedProducts::RecommendationsResolver < Graph::Resolvers::BaseSearch
  scope { object.recommendations }

  class OrderType < Graph::Types::BaseEnum
    graphql_name 'RecommendedProductRecommendationOrder'

    value 'VOTES'
  end

  option :order, type: OrderType

  private

  def apply_order_with_votes(scope)
    scope.by_credible_votes_count.by_date(:asc)
  end
end
