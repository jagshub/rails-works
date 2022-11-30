# frozen_string_literal: true

class Graph::Resolvers::GoldenKitty::Category < Graph::Resolvers::Base
  argument :year, Int, required: true
  argument :slug, String, required: true

  type Graph::Types::GoldenKittyCategoryType, null: true

  def resolve(year:, slug:)
    GoldenKitty::Category
      .joins(:edition)
      .where(slug: slug, golden_kitty_editions: { year: year })
      .first
  end
end
