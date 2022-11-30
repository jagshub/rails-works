# frozen_string_literal: true

module Anthologies::FeaturedStories
  extend self

  Result = Struct.new(:first_section, :second_section, :category_section)

  def call
    first_section = ::Anthologies::Story.find_by(featured_position: :first_section)
    second_section = ::Anthologies::Story.find_by(featured_position: :second_section)

    category_section =
      ::Anthologies::Story
      .where(category: :maker_stories, featured_position: nil)
      .published
      .by_published_at
      .limit(4)

    Result.new(
      first_section,
      second_section,
      category_section,
    )
  end
end
