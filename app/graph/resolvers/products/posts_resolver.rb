# frozen_string_literal: true

class Graph::Resolvers::Products::PostsResolver < Graph::Resolvers::BaseSearch
  scope { object.posts.visible }

  class FilterType < Graph::Types::BaseEnum
    graphql_name 'ProductsPostsFilter'

    value 'ALL'
    value 'FEATURED'
  end

  class OrderType < Graph::Types::BaseEnum
    graphql_name 'ProductsPostsOrder'

    value 'DATE'
    value 'VOTES'
  end

  option :filter, type: FilterType
  option :order, type: OrderType

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
