# frozen_string_literal: true

class Mobile::Graph::Resolvers::Search::UserResolver < Mobile::Graph::Resolvers::BaseResolver
  type Mobile::Graph::Types::UserType.connection_type, null: false

  argument :query, String, required: true

  def resolve(query:)
    Search.query_user(query, maker: false, hunter: false)
  end
end
