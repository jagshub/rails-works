# frozen_string_literal: true

module API::V2Internal::Types
  # NOTE(dhruvparmar372): Borrowed from https://github.com/rmosolgo/graphql-ruby/wiki/How-To:-Set-a-Custom-Base-Connection-class-to-provide-totalCount-and-totalPageCount-fields-on-all-Connections
  class BaseConnection < GraphQL::Types::Relay::BaseConnection
    node_nullable false
    edges_nullable false
    edge_nullable false

    field :count, Integer, 'Total # of objects returned from this Plural Query', null: false

    field :total_count, Integer, 'Total # of objects returned from this Plural Query', null: false

    def count
      object.items&.count || 0
    end

    def total_count
      object.items&.count || 0
    end
  end
end
