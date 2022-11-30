# frozen_string_literal: true

module Graph::Types
  class UpcomingPageMessageMetricsType < BaseObject
    graphql_name 'UpcomingPageMessageMetrics'

    field :open_rate, Float, null: false
    field :click_rate, Float, null: false
  end
end
