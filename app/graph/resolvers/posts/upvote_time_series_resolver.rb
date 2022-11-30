# frozen_string_literal: true

module Graph::Resolvers
  class Posts::UpvoteTimeSeriesResolver < Graph::Resolvers::Base
    # NOTE(DZ): This is used for area chart in highcharts. Can be extracted
    # for a generic x-y chart data type
    class TimeSeriesType < Graph::Types::BaseObject
      graphql_name 'PostUpvoteTimeSeriesPoint'

      field :timestamp, GraphQL::Types::BigInt, null: false, description: 'JS timestamp (ms)'
      field :value, Float, null: false
    end

    type [TimeSeriesType], null: false

    LAUNCH_DAY_POST_ID = 161_010

    def resolve
      if object.id == LAUNCH_DAY_POST_ID ||
         ApplicationPolicy.can?(current_user, :maintain, object)
        ::Posts::Statistics.generate_stats_for_launch_day_chart(object)
      else
        []
      end
    end
  end
end
