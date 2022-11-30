# frozen_string_literal: true

module Mobile::Graph::Types
  class Anthologies::FeaturedStoryType < BaseObject
    field :first_section, Mobile::Graph::Types::Anthologies::StoryType, null: true
    field :second_section, Mobile::Graph::Types::Anthologies::StoryType, null: true
    field :category_section, [Mobile::Graph::Types::Anthologies::StoryType], null: false
  end
end
