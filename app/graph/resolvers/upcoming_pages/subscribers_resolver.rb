# frozen_string_literal: true

class Graph::Resolvers::UpcomingPages::SubscribersResolver < Graph::Resolvers::BaseSearch
  scope { ApplicationPolicy.can?(current_user, ApplicationPolicy::MAINTAIN, object) ? object.confirmed_subscribers.not_spammer.by_created_at : UpcomingPageSubscriber.none }

  option :search_id, type: ID, with: :apply_saved_search
  option :filters, type: [Graph::Types::UpcomingPageSubscriberFilterInputType], required: false, with: :apply_filters
  option :order, type: Graph::Types::SortOrderType
  option :sort, type: String, with: :apply_sort

  type Graph::Types::UpcomingPageSubscriberType.connection_type, null: false

  private

  def apply_saved_search(scope, search_id)
    return if search_id.blank?

    search = object.subscriber_searches.find_by id: search_id

    return if search.blank?

    apply_filters scope, search.filters
  end

  def apply_filters(scope, filters)
    ::UpcomingPages::SubscriberSearch.new(object).apply(scope, filters&.map(&:to_h)&.map(&:stringify_keys))
  end

  def apply_sort(scope, value)
    order = params['order'] == 'asc' ? 'asc' : 'desc'

    case value
    when 'created_at' then scope.reorder(Arel.sql("upcoming_page_subscribers.created_at #{ order }"))
    when 'followers' then scope.reorder(Arel.sql("users.follower_count #{ order } NULLS LAST"))
    when 'name' then scope.reorder(Arel.sql("users.name #{ order } NULLS LAST "))
    end
  end

  def apply_order_with_asc(scope)
    scope
  end

  def apply_order_with_desc(scope)
    scope
  end
end
