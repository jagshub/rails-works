# frozen_string_literal: true

class Mobile::Graph::Resolvers::Stories::Related < Mobile::Graph::Resolvers::BaseResolver
  type Mobile::Graph::Types::Anthologies::StoryType.connection_type, null: false

  def resolve
    object.related_stories
  end
end
