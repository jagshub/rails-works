# frozen_string_literal: true

class Graph::Resolvers::Products::AddonsResolver < Graph::Resolvers::BaseSearch
  scope { object.addons }

  class OrderType < Graph::Types::BaseEnum
    graphql_name 'ProductsAddonsOrder'

    value 'rating'
    value 'followers'
    value 'votes'
    value 'recency'
  end

  option :order, type: OrderType
  option :query, type: String, with: :for_query

  def apply_order_with_votes(scope)
    scope.order('sort_key_max_votes DESC')
  end

  def apply_order_with_rating(scope)
    scope.order('reviews_rating DESC, reviews_count DESC')
  end

  def apply_order_with_followers(scope)
    scope.order('followers_count DESC')
  end

  def apply_order_with_recency(scope)
    scope.order('latest_post_at DESC')
  end

  private

  def for_query(scope, value)
    return if value.blank?

    scope.where '(name ILIKE :query OR tagline ILIKE :query)', query: LikeMatch.by_words(query)
  end
end
