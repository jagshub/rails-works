# frozen_string_literal: true

class Graph::Resolvers::Search::CollectionResolver < Graph::Resolvers::Base
  type Graph::Types::CollectionType.connection_type, null: false

  argument :query, String, required: false

  def resolve(query:, **options)
    Search.query_collection(query, **options)
  end
end
