# frozen_string_literal: true

class Graph::Resolvers::Anthologies::MoreStoriesResolver < Graph::Resolvers::Base
  type [Graph::Types::Anthologies::StoryType], null: false

  argument :limit, Integer, required: true

  def resolve(limit:)
    ::Anthologies::Story
      .published
      .by_published_at
      .where.not(id: object.id)
      .limit(limit)
  end
end
