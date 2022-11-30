# frozen_string_literal: true

class Mobile::Graph::Resolvers::Search::PostResolver < Mobile::Graph::Resolvers::BaseResolver
  type Mobile::Graph::Types::PostType.connection_type, null: false

  argument :query, String, required: true

  def resolve(query:)
    Search.query_post(query)
  end
end
