# frozen_string_literal: true

module Graph::Types
  class Anthologies::FeaturedStoryType < BaseObject
    field :first_section, Graph::Types::Anthologies::StoryType, null: true
    field :second_section, Graph::Types::Anthologies::StoryType, null: true
    field :category_section, [Graph::Types::Anthologies::StoryType], null: false
  end
end
