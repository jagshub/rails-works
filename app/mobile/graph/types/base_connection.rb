# frozen_string_literal: true

module Mobile::Graph::Types
  # NOTE(dhruvparmar372): Borrowed from https://github.com/rmosolgo/graphql-ruby/wiki/How-To:-Set-a-Custom-Base-Connection-class-to-provide-totalCount-and-totalPageCount-fields-on-all-Connections
  class BaseConnection < GraphQL::Types::Relay::BaseConnection
    node_nullable false
    edges_nullable false
    edge_nullable false

    field :total_count, Integer, 'Total # of objects returned from this Plural Query', null: false

    def page_info
      if object.is_a?(GraphQL::Pagination::ActiveRecordRelationConnection)
        Graph::Common::FastPageInfo.new(object)
      else
        object
      end
    end

    def total_count
      if object.respond_to? :total_count
        object.total_count
      else
        object.items&.count || 0
      end
    end
  end
end
