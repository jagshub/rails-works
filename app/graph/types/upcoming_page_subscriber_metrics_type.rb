# frozen_string_literal: true

module Graph::Types
  class UpcomingPageSubscriberMetricsType < BaseObject
    graphql_name 'UpcomingPageSubscriberMetrics'

    field :period, Graph::Types::DateTimeType, hash_key: :period, null: false
    field :value, Int, hash_key: :value, null: false
  end
end
