# frozen_string_literal: true

class Graph::Resolvers::FounderClub::SearchResolver < Graph::Resolvers::BaseSearch
  scope { ::FounderClub::Deal.active.ordered_by_user_claim(current_user) }

  class OrderType < Graph::Types::BaseEnum
    graphql_name 'DealsOrder'

    value 'recommended'
    value 'newest'
    value 'popular'
  end

  option(:order, type: OrderType, default: 'recommended')
  option(:query, type: String, with: :for_query)
  option :include_deal_id, type: GraphQL::Types::ID, with: :apply_include_deal_id

  def for_query(scope, value)
    return if value.blank?

    scope.search_by_title_or_company_name(value)
  end

  def apply_order_with_newest(scope)
    scope.order(created_at: :desc)
  end

  def apply_order_with_recommended(scope)
    scope.by_priority
  end

  def apply_order_with_popular(scope)
    scope.by_popularity.by_priority
  end

  def apply_include_deal_id(scope, _deal_id)
    deal = ::FounderClub::Deal.find_by(id: params['include_deal_id']) if params['include_deal_id']

    return scope if deal.blank?

    ::FounderClub::Deal.order([Arel.sql('id = ? DESC'), deal.id])
  end
end
