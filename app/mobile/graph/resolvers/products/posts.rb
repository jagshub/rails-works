# frozen_string_literal: true

class Mobile::Graph::Resolvers::Products::Posts < Mobile::Graph::Resolvers::BaseSearchResolver
  scope { object.posts.visible }

  class FilterType < Mobile::Graph::Types::BaseEnum
    graphql_name 'ProductsPostsFilter'

    value 'ALL'
    value 'FEATURED'
  end

  class OrderType < Mobile::Graph::Types::BaseEnum
    graphql_name 'ProductsPostsOrder'

    value 'DATE'
    value 'VOTES'
  end

  option :filter, type: FilterType
  option :order, type: OrderType, default: 'DATE'

  def apply_filter_with_all(scope)
    scope
  end

  def apply_filter_with_featured(scope)
    scope.featured
  end

  def apply_order_with_date(scope)
    scope.by_created_at
  end

  def apply_order_with_votes(scope)
    scope.by_votes
  end
end
