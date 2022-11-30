# frozen_string_literal: true

class Mobile::Graph::Resolvers::Search::CollectionResolver < Mobile::Graph::Resolvers::BaseResolver
  type Mobile::Graph::Types::CollectionType.connection_type, null: false

  argument :query, String, required: false

  def resolve(query:)
    Search.query_collection(query)
  end
end
