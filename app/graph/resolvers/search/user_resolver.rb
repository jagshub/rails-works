# frozen_string_literal: true

class Graph::Resolvers::Search::UserResolver < Graph::Resolvers::Base
  type Graph::Types::Search::UserConnectionType, null: false

  argument :query, String, required: true
  argument :maker, Boolean, required: false
  argument :hunter, Boolean, required: false

  def resolve(query:, maker: false, hunter: false)
    Search.query_user(query, maker: maker, hunter: hunter)
  end
end
