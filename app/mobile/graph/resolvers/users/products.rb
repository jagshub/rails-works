# frozen_string_literal: true

class Mobile::Graph::Resolvers::Users::Products < Mobile::Graph::Resolvers::BaseSearchResolver
  type Mobile::Graph::Types::ProductType.connection_type, null: false

  scope { object.new_products }

  class OrderType < Mobile::Graph::Types::BaseEnum
    graphql_name 'ProductsOrder'

    value 'DEFAULT'
    value 'LATEST_POST'
  end

  option :order, type: OrderType, default: 'DEFAULT'

  def apply_order_with_default(scope)
    scope
  end

  def apply_order_with_latest_post(scope)
    scope
      .select('DISTINCT(products.*), MAX(posts.scheduled_at) as post_scheduled_at')
      .joins(:posts)
      .group('products.id')
      .where('posts.podcast': false)
      .order('post_scheduled_at DESC')
  end
end
