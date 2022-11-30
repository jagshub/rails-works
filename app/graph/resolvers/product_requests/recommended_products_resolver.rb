# frozen_string_literal: true

class Graph::Resolvers::ProductRequests::RecommendedProductsResolver < Graph::Resolvers::BaseSearch
  scope { object.recommended_products }

  class FilterType < Graph::Types::BaseEnum
    graphql_name 'ProductRequestRecommendedProductFilter'

    value 'FEATURED'
  end

  class OrderType < Graph::Types::BaseEnum
    graphql_name 'ProductRequestRecommendedProductOrder'

    value 'VOTES'
  end

  option :filter, type: FilterType
  option :order, type: OrderType

  private

  def apply_filter_with_featured(scope)
    scope.featured
  end

  def apply_order_with_votes(scope)
    scope.by_credible_votes_count_ranking.by_date
  end
end
