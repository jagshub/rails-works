# frozen_string_literal: true

class Graph::Resolvers::ProductRequests::SearchResolver < Graph::Resolvers::BaseSearch
  scope { ProductRequest.visible }

  class FilterType < Graph::Types::BaseEnum
    graphql_name 'ProductRequestFilter'

    value 'ALL_TIME'
    value 'FEATURED'
    value 'NEEDS_HELP'
    value 'RECENT'
  end

  option :exclude, type: GraphQL::Types::ID, with: :apply_exclude
  option :filter, type: FilterType

  private

  def apply_filter_with_all_time(scope)
    scope
      .product_request
      .by_recommended_products_count
  end

  def apply_filter_with_featured(scope)
    scope.featured
  end

  def apply_filter_with_needs_help(scope)
    scope
      .product_request
      .featured
      .needs_help.by_date
  end

  def apply_filter_with_recent(scope)
    scope
      .not_duplicate
      .by_date
  end

  def apply_exclude(scope, value)
    scope.where.not(id: value)
  end
end
