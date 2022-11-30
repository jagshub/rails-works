# frozen_string_literal: true

module Graph::Types
  class BaseConnection < GraphQL::Types::Relay::BaseConnection
    node_nullable false
    edges_nullable false
    edge_nullable false

    field :total_count, Integer, 'Total # of objects returned from this Plural Query', null: false

    def total_count
      if object.respond_to? :total_count
        object.total_count
      else
        object.items&.count || 0
      end
    end

    def page_info
      if object.is_a?(GraphQL::Pagination::ActiveRecordRelationConnection)
        Graph::Common::FastPageInfo.new(object)
      else
        object
      end
    end
  end
end
