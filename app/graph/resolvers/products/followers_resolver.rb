# frozen_string_literal: true

class Graph::Resolvers::Products::FollowersResolver < Graph::Resolvers::BaseSearch
  scope { object.followers }

  class OrderType < Graph::Types::BaseEnum
    graphql_name 'ProductsFollowersOrder'

    value 'latest'
    value 'popularity'
    value 'friends'
  end

  option :order, type: OrderType, default: 'latest'
  option :exclude_viewer, type: Boolean, default: false, with: :apply_exclude_viewer

  def apply_order_with_latest(scope)
    scope.merge(Subscription.order(updated_at: :desc))
  end

  def apply_order_with_popularity(scope)
    scope.by_follower_count
  end

  def apply_order_with_friends(scope)
    return scope unless current_user

    scope.order_by_friends(current_user.id)
  end

  def apply_exclude_viewer(scope, value)
    if value && current_user
      scope.where.not(id: current_user.id)
    else
      scope
    end
  end
end
