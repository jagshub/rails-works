# frozen_string_literal: true

class Graph::Resolvers::Search::ProductResolver < Graph::Resolvers::Base
  type Graph::Types::ProductType.connection_type, null: false

  argument :query, String, required: true
  argument :last_launched_after, String, required: false
  argument :maker, String, required: false

  def resolve(query:, **options)
    Search.query_product(query, **options)
  end
end
