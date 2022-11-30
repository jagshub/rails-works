# frozen_string_literal: true

module API::V2::Types
  class BaseEdge < GraphQL::Types::Relay::BaseEdge
    description 'An edge in a connection.'

    class << self
      def node_type(node_type = nil)
        if node_type
          @node_type = node_type
          field :node, node_type, null: false, description: 'The item at the end of the edge.' do
            # NOTE(dhruvparmar372): Using 20 here instead of actual count of results
            # based on the query arguments since it's not possible to fetch parent
            # level arguments currently. https://github.com/rmosolgo/graphql-ruby/issues/881#issuecomment-383117637
            complexity ->(_ctx, _args, child_complexity) { 20 * child_complexity }
          end
        end
        @node_type
      end
    end

    field :cursor, String, null: false, description: 'A cursor for use in pagination.'
  end
end
