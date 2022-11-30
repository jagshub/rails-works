# frozen_string_literal: true

class Graph::Resolvers::UpcomingPages::DeliveriesResolver < Graph::Resolvers::BaseSearch
  scope { ApplicationPolicy.can?(current_user, ApplicationPolicy::MAINTAIN, object) ? object.deliveries : UpcomingPageMessageDelivery.none }

  class FilterType < Graph::Types::BaseEnum
    graphql_name 'UpcomingPageMessageDeliveryFilter'

    value 'SENT'
    value 'OPENED'
    value 'CLICKED'
    value 'FAILED'
  end

  option :filter, type: FilterType, default: 'SENT'
  option :subscriber, type: String, with: :apply_subscriber

  type Graph::Types::UpcomingPageMessageDeliveryType.connection_type, null: false

  private

  def apply_filter_with_sent(scope)
    scope.sent.by_sent
  end

  def apply_filter_with_opened(scope)
    scope.opened.by_opened
  end

  def apply_filter_with_clicked(scope)
    scope.clicked.by_clicked
  end

  def apply_filter_with_failed(scope)
    scope.failed.by_failed
  end

  def apply_subscriber(scope, value)
    scope.joins(:subscriber).merge(UpcomingPageSubscriber.for_query(value))
  end
end
