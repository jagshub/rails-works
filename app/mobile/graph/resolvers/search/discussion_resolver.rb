# frozen_string_literal: true

class Mobile::Graph::Resolvers::Search::DiscussionResolver < Mobile::Graph::Resolvers::BaseResolver
  type Mobile::Graph::Types::Discussion::ThreadType.connection_type, null: false

  argument :query, String, required: true

  def resolve(query:)
    Search.query_discussion(query)
  end
end
