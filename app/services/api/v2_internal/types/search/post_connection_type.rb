# frozen_string_literal: true

module API::V2Internal::Types
  class Search::PostConnectionType < BaseConnection
    # NOTE(DZ): GraphQL name is reflective of legacy search. The resolver
    # no longer uses algolia
    graphql_name 'AlgoliaConnection'

    edge_type API::V2Internal::Types::PostType.edge_type
  end
end
