# frozen_string_literal: true

module Graph::Types
  class Search::UserConnectionType < BaseConnection
    graphql_name 'UserSearchConnection'

    edge_type Graph::Types::UserType.edge_type

    field :results_count, Integer, null: false

    # NOTE(DZ): Search conversion from the web is tracked based on `track`
    # param. If `track` is true, then search_id will be present.
    field :search_id,
          Integer,
          null: true,
          description: 'For conversion tracking in mutation :search_conversion'
  end
end
