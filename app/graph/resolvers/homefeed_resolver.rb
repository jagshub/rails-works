# frozen_string_literal: true

class Graph::Resolvers::HomefeedResolver < Graph::Resolvers::Base
  type Graph::Types::HomefeedConnectionCustomType, null: false

  argument :after, String, required: false
  argument :kind, Graph::Types::HomefeedKindEnum, required: true

  def resolve(after: nil, kind: nil)
    ::Homefeed.feed_for(after: after, kind: kind, graphql_context: context)
  end
end
