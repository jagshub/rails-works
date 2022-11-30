# frozen_string_literal: true

module Graph::Types
  class UpcomingPageSubscriberConnection < BaseConnection
    graphql_name 'UpcomingPageSubscriberCon'

    edge_type Graph::Types::UpcomingPageSubscriberType.edge_type
  end
end
