# frozen_string_literal: true

module Graph::Resolvers
  class UpcomingPages::SubscriberMetricsResolver < Graph::Resolvers::Base
    FIELDS = %i(
      value
    ).freeze

    type [Graph::Types::UpcomingPageSubscriberMetricsType], null: false

    def resolve
      return [] unless ApplicationPolicy.can?(current_user, ApplicationPolicy::MAINTAIN, object)

      periods = object.subscribers.confirmed.select('COUNT(1) as value', "date_trunc('day', upcoming_page_subscribers.created_at) AS period").group(:period).order('period ASC').map do |row|
        { period: row.period, value: row.value }
      end

      ::UpcomingPages::Metrics.fill_missing_intervals(periods, FIELDS)
    end
  end
end
