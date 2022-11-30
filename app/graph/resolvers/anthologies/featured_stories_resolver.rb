# frozen_string_literal: true

class Graph::Resolvers::Anthologies::FeaturedStoriesResolver < Graph::Resolvers::Base
  type Graph::Types::Anthologies::FeaturedStoryType, null: false

  def resolve
    ::Anthologies.index_page_featured_stories
  end
end
