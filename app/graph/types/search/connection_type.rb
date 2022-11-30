# frozen_string_literal: true

module Graph::Types
  class Search::ConnectionType < BaseConnection
    class TopicAggregationType < BaseObject
      graphql_name 'SearchTopicAggregation'

      field :topic, Graph::Types::TopicType, null: false
      field :count, Integer, null: false
    end

    class AggregationType < BaseObject
      graphql_name 'SearchAggregation'

      field(
        :topics,
        [TopicAggregationType],
        null: false,
        description: 'Aggregated buckets of topics based on results from query',
      )
    end

    graphql_name 'SearchConnection'

    edge_type Graph::Types::Search::SearchableUnionType.edge_type

    field :results_count, Integer, null: false
    field :aggregations, AggregationType, null: false

    # NOTE(DZ): Search conversion from the web is tracked based on `track`
    # param. If `track` is true, then search_id will be present.
    field :search_id,
          Integer,
          null: true,
          description: 'For conversion tracking in mutation :search_conversion'
  end
end
