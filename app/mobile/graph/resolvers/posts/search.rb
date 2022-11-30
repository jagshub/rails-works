# frozen_string_literal: true

class Mobile::Graph::Resolvers::Posts::Search < Mobile::Graph::Resolvers::BaseSearchResolver
  scope { Post.visible }

  class OrderType < Graph::Types::BaseEnum
    graphql_name 'PostsOrder'

    value 'DAILY_RANK'
    value 'MONTHLY_RANK'
    value 'VOTES'
  end

  type Mobile::Graph::Types::PostType.connection_type, null: false

  option :featured_after, type: Mobile::Graph::Types::DateType, with: :for_featured_after
  option :featured_before, type: Mobile::Graph::Types::DateType, with: :for_featured_before
  option :order, type: OrderType, default: 'VOTES'

  def apply_order_with_daily_rank(scope)
    scope.order('daily_rank ASC')
  end

  def apply_order_with_monthly_rank(scope)
    scope.order('monthly_rank ASC')
  end

  def apply_order_with_votes(scope)
    scope.by_credible_votes
  end

  private

  def for_featured_after(scope, value)
    return if value.blank?

    scope.where('DATE(featured_at) >= ?', value.to_date)
  end

  def for_featured_before(scope, value)
    return if value.blank?

    scope.where('DATE(featured_at) <= ?', value.to_date)
  end
end
