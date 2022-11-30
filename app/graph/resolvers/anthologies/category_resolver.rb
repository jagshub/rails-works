# frozen_string_literal: true

class Graph::Resolvers::Anthologies::CategoryResolver < Graph::Resolvers::Base
  argument :slug, String, required: true

  type Graph::Types::Anthologies::CategoryType, null: true

  def resolve(slug:)
    ::Anthologies.story_category(slug)
  end
end
