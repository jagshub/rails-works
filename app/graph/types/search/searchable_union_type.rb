# frozen_string_literal: true

module Graph::Types
  class Search::SearchableUnionType < BaseUnion
    graphql_name 'SearchableUnion'

    possible_types(
      Graph::Types::Anthologies::StoryType,
      Graph::Types::Discussion::ThreadType,
      Graph::Types::ProductType,
      Graph::Types::PostType,
      Graph::Types::UserType,
      Graph::Types::UpcomingPageType,
      Graph::Types::TopicType,
    )
  end
end
