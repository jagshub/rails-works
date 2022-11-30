# frozen_string_literal: true

module API::V2::Types
  class BaseConnection < GraphQL::Types::Relay::BaseConnection
    node_nullable false
    edges_nullable false
    edge_nullable false

    field :total_count, Integer, 'Total number of objects returned from this query', null: false

    def total_count
      object.nodes&.size
    end
  end
end
