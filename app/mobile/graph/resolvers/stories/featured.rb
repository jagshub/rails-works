# frozen_string_literal: true

class Mobile::Graph::Resolvers::Stories::Featured < Mobile::Graph::Resolvers::BaseResolver
  type Mobile::Graph::Types::Anthologies::FeaturedStoryType, null: false

  def resolve
    ::Anthologies.index_page_featured_stories
  end
end
