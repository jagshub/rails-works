# frozen_string_literal: true

module Mobile::Graph::Resolvers
  class Homefeed < BaseResolver
    type Mobile::Graph::Types::HomefeedConnectionCustomType, null: false

    argument :after, String, required: false
    argument :kind, Mobile::Graph::Types::HomefeedKindEnum, required: true

    def resolve(kind:, after: nil)
      ::Homefeed.feed_for(
        kind: kind,
        after: after,
        graphql_context: context,
        mobile: true,
      )
    end
  end
end
