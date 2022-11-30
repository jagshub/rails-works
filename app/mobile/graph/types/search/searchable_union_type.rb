# frozen_string_literal: true

module Mobile::Graph::Types
  class Search::SearchableUnionType < BaseUnion
    graphql_name 'SearchableUnion'

    possible_types(
      Mobile::Graph::Types::Anthologies::StoryType,
      Mobile::Graph::Types::Discussion::ThreadType,
      Mobile::Graph::Types::PostType,
      Mobile::Graph::Types::UserType,
      Mobile::Graph::Types::TopicType,
      Mobile::Graph::Types::ProductType,
    )
  end
end
